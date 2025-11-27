import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import '../../providers/data_provider.dart';
import '../../widgets/order_card.dart';

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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate this Dish'),
          content: Column(
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
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Leave a sweet note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
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
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<DataProvider>().orders;
    // Sort by date desc
    final sortedOrders = List<Order>.from(orders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: sortedOrders.isEmpty
          ? const Center(child: Text('No orders yet. Go eat something!'))
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
                    ],
                  ),
                );
              },
            ),
    );
  }
}
