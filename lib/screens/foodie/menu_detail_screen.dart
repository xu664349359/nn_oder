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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image (Hero)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Hero(
              tag: 'menu_image_${widget.menuItem.id}',
              child: Image.network(
                widget.menuItem.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
              ),
            ),
          ),
          
          // Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 320), // Start content below image area
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.menuItem.name,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2D2D2D),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.favorite, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.menuItem.intimacyPrice}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Rating & Stats Row
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              const Text(
                                '4.8',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(128 reviews)',
                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              ),
                              const Spacer(),
                              const Icon(Icons.access_time_filled, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '15-20 min',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Description
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.menuItem.description,
                            style: TextStyle(height: 1.5, color: Colors.grey[700], fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          
                          // Ingredients Tags
                          Text(
                            'Ingredients',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: widget.menuItem.ingredients.map((e) => _buildTag(e)).toList(),
                          ),
                          const SizedBox(height: 24),
                          
                          // Cooking Steps
                          Text(
                            'Cooking Steps',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ...widget.menuItem.steps.asMap().entries.map((entry) => _buildStepItem(entry.key, entry.value)).toList(),
                          
                          const SizedBox(height: 300), // Extra space for scrolling above bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button & Actions
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _buildGlassButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                _buildGlassButton(
                  icon: Icons.share,
                  onTap: () {}, // TODO: Share
                ),
                const SizedBox(width: 12),
                _buildGlassButton(
                  icon: Icons.favorite_border,
                  onTap: () {}, // TODO: Favorite
                ),
              ],
            ),
          ),
          
          // Bottom Cart Action Bar (Floating)
          Positioned(
            left: 16,
            right: 16,
            bottom: SafeAreaCalculator.bottom(context) + 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          color: _quantity > 1 ? Colors.black : Colors.grey,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAddingToCart ? null : _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isAddingToCart
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_bag_outlined),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.addToCart,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 1, end: 0, duration: 500.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildStepItem(int index, RecipeStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.description,
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF444444)),
                ),
                if (step.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      step.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX();
  }
}

class SafeAreaCalculator {
  static double bottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom > 0 
        ? MediaQuery.of(context).padding.bottom 
        : 16.0;
  }
}
