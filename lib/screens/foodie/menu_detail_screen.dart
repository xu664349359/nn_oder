import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../models/menu_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../router.dart';
import '../../widgets/modern_dialog.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItem menuItem;

  const MenuDetailScreen({super.key, required this.menuItem});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  bool _isAddingToCart = false;
  int _quantity = 1;

  Future<void> _addToCart() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isAddingToCart = true);

    try {
      await context.read<CartProvider>().addItem(
        user.id,
        widget.menuItem.id,
        quantity: _quantity,
      );

      if (mounted) {
        ModernDialog.show(
          context: context,
          title: 'Added to Cart!',
          icon: Icons.check_circle,
          iconColor: Colors.green,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.menuItem.imageUrl,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    width: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.menuItem.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: $_quantity',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Shopping'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final ctx = rootNavigatorKey.currentContext;
                if (ctx != null) {
                  ctx.push('/foodie/cart');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Cart'),
            ),
          ],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
                  Image.network(
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
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      icon: const Icon(Icons.remove),
                      color: AppColors.primary,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: const Icon(Icons.add),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _isAddingToCart ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isAddingToCart
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_outlined),
                            const SizedBox(width: 8),
                            Text(l10n.addToCart),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
