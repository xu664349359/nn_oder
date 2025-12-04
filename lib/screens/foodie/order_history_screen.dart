import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchOrders();
    });
  }

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
    // Sort by date desc
    final sortedOrders = List<Order>.from(orders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orders)),
      body: sortedOrders.isEmpty
          ? Center(child: Text(l10n.noDishes))
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                final order = sortedOrders[index];
                return GestureDetector(
                  onTap: () {
                    if (order.status == OrderStatus.completed && order.rating == null) {
                      _showRatingDialog(order);
                    }
                  },
                  child: Stack(
                    children: [
                      OrderCard(order: order),
                      if (order.status == OrderStatus.completed && order.rating == null)
                        Positioned(
                          right: 16,
                          top: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Tap to Rate',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      // Show wash dishes badge
                      if (order.washDishes)
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cleaning_services, size: 12, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.washDishes,
                                  style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
