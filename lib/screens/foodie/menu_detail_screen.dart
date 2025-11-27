import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../models/menu_model.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItem menuItem;

  const MenuDetailScreen({super.key, required this.menuItem});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  bool _isOrdering = false;
  bool _showSuccess = false;

  Future<void> _placeOrder() async {
    final user = context.read<AuthProvider>().currentUser;
    final intimacy = context.read<DataProvider>().intimacy;

    if (user == null) return;

    if ((intimacy?.value ?? 0) < widget.menuItem.intimacyPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough love points! Go hug your Chef! ❤️')),
      );
      return;
    }

    setState(() => _isOrdering = true);

    // Create order
    final order = Order(
      id: const Uuid().v4(),
      foodieId: user.id,
      chefId: user.partnerId!, // Assumes bound
      menuItemId: widget.menuItem.id,
      menuItemName: widget.menuItem.name,
      menuItemImage: widget.menuItem.imageUrl,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    // Deduct intimacy
    await context.read<DataProvider>().updateIntimacy(
      -widget.menuItem.intimacyPrice,
      'Ordered ${widget.menuItem.name}',
    );

    // Place order
    await context.read<DataProvider>().createOrder(order);

    setState(() {
      _isOrdering = false;
      _showSuccess = true;
    });

    // Wait for animation then go back
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/foodie/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: AppColors.primary, size: 100)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Order Sent with Love!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.menuItem.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.menuItem.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.menuItem.intimacyPrice}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.menuItem.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.menuItem.ingredients.map((e) => Chip(label: Text(e))).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Steps',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.menuItem.steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(entry.value.description)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isOrdering ? null : _placeOrder,
        icon: _isOrdering
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
            : const Icon(Icons.favorite),
        label: Text(_isOrdering ? 'Sending...' : 'I Want This!'),
        backgroundColor: AppColors.accent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
