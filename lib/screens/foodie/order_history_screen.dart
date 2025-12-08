import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import '../../providers/data_provider.dart';
import '../../widgets/order_card.dart';
import '../../widgets/modern_dialog.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin { // Added TickerProvider
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ... existing methods (_showRatingDialog, _formatTime, _formatDate) remain or will be moved

  void _showRatingDialog(Order order) {
     int rating = 5;
    final commentController = TextEditingController();

    ModernDialog.show(
      context: context,
      title: 'Rate this Dish',
      icon: Icons.star,
      iconColor: Colors.amber,
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Leave a sweet note...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<DataProvider>().rateOrder(
              order.id,
              rating,
              commentController.text,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = context.watch<DataProvider>().orders;
    
    // Sort and Filter
    final sortedOrders = List<Order>.from(orders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final now = DateTime.now();
    final todayOrders = sortedOrders.where((o) => 
      o.createdAt.year == now.year && 
      o.createdAt.month == now.month && 
      o.createdAt.day == now.day
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft flat background
      appBar: AppBar(
        title: Text(l10n.orders, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: [
            Tab(text: 'Today'), // Use l10n in real app if available, hardcoded for now based on request
            Tab(text: 'All Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineList(context, todayOrders, isToday: true),
          _buildTimelineList(context, sortedOrders, isToday: false),
        ],
      ),
    );
  }

  Widget _buildTimelineList(BuildContext context, List<Order> orders, {required bool isToday}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300])
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      );
    }

    // Grouping
    final List<List<Order>> groupedOrders = [];
    if (orders.isNotEmpty) {
      List<Order> currentGroup = [orders.first];
      for (int i = 1; i < orders.length; i++) {
        final order = orders[i];
        final lastOrder = currentGroup.last;
        if (lastOrder.createdAt.difference(order.createdAt).inMinutes.abs() < 60) {
           currentGroup.add(order);
        } else {
          groupedOrders.add(currentGroup);
          currentGroup = [order];
        }
      }
      groupedOrders.add(currentGroup);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: groupedOrders.length,
      itemBuilder: (context, index) {
        final group = groupedOrders[index];
        return _buildTimelineItem(context, group, index, groupedOrders.length);
      },
    );
  }

  Widget _buildTimelineItem(BuildContext context, List<Order> group, int index, int total) {
    final firstOrder = group.first;
    final totalItems = group.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = group.fold(0, (sum, item) => sum + (item.actualIntimacyCost ?? 0));
    final isCompleted = group.every((o) => o.status == OrderStatus.completed);
    final isCooking = group.any((o) => o.status == OrderStatus.cooking);
    
    String statusText;
    Color statusColor;
    if (isCompleted) {
      statusText = AppLocalizations.of(context)!.done;
      statusColor = Colors.green;
    } else if (isCooking) {
      statusText = AppLocalizations.of(context)!.cooking;
      statusColor = Colors.blue;
    } else {
      statusText = AppLocalizations.of(context)!.pending;
      statusColor = Colors.orange;
    }
    
    // Timeline connector logic
    final isLast = index == total - 1;

    return Stack(
      children: [
        // Connector Line
        if (!isLast)
          Positioned(
            top: 28, // Adjust based on time text height + spacer
            left: 21, // Centered below the dot (width 12 + margin/padding)
            bottom: 0,
            child: Container(
              width: 2,
              color: Colors.grey[200],
            ),
          ),
          
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Column elements (Time + Dot)
            SizedBox(
              width: 44, // Fixed width for alignment
              child: Column(
                children: [
                  Text(
                    _formatTime(firstOrder.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24), // Spacing between items
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    shape: const Border(), // Remove default borders
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0), // Soft pink background
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.restaurant, color: AppColors.primary.withOpacity(0.8), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalItems Items',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '$totalPrice',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.favorite, size: 14, color: AppColors.primary),
                      ],
                    ),
                    children: group.map((order) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey[100]!)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                order.menuItemImage,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_,__,___) => Container(width: 40, height: 40, color: Colors.grey[100]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.menuItemName, 
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  Text(
                                    'x${order.quantity}',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (order.status == OrderStatus.completed && order.rating == null)
                              InkWell(
                                onTap: () => _showRatingDialog(order),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Rate',
                                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.1, end: 0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month}.${date.day}';
  }
}
