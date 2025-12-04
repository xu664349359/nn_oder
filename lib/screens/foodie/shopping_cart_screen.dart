import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../models/cart_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<CartProvider>().loadCart(user.id);
        context.read<AuthProvider>().refreshBalance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingCart),
        centerTitle: true,
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.cart.items.isEmpty
              ? _buildEmptyCart(context, l10n)
              : _buildCartList(context, cartProvider, l10n, user.id),
      bottomNavigationBar: cartProvider.cart.items.isEmpty
          ? null
          : _buildBottomBar(context, cartProvider, authProvider, l10n),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n.cartEmpty,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    CartProvider provider,
    AppLocalizations l10n,
    String userId,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = provider.cart.items[index];
        return _buildCartItem(context, provider, item, l10n, userId);
      },
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider provider,
    CartItem item,
    AppLocalizations l10n,
    String userId,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.menuItem.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.menuItem.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                            onPressed: () => provider.removeItem(userId, item.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${item.menuItem.intimacyPrice}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: item.quantity > 1
                                  ? () => provider.updateItem(userId, item.id, quantity: item.quantity - 1)
                                  : null,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => provider.updateItem(userId, item.id, quantity: item.quantity + 1),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Wash Dishes Option
            InkWell(
              onTap: () => provider.updateItem(userId, item.id, washDishes: !item.washDishes),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: item.washDishes,
                      onChanged: (val) => provider.updateItem(userId, item.id, washDishes: val),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.washDishes),
                  const Spacer(),
                  if (item.washDishes)
                    Text(
                      '-${item.discount}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (item.washDishes)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Row(
                  children: [
                    Text(
                      l10n.dishWashingDiscount,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
    AppLocalizations l10n,
  ) {
    final cart = cartProvider.cart;
    final balance = authProvider.currentUser?.intimacyBalance ?? 0;
    final canCheckout = balance >= cart.totalFinalPrice;

    return Container(
      padding: const EdgeInsets.all(20),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.subtotal, style: const TextStyle(color: Colors.grey)),
                Text('${cart.totalBasePrice}'),
              ],
            ),
            if (cart.totalDiscount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.discount, style: const TextStyle(color: Colors.green)),
                  Text('-${cart.totalDiscount}', style: const TextStyle(color: Colors.green)),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      '${cart.totalFinalPrice}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Balance Check
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${l10n.intimacyBalance}: $balance',
                  style: TextStyle(
                    color: canCheckout ? Colors.grey[600] : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCheckout ? () => context.push('/foodie/checkout') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  canCheckout ? l10n.checkout : l10n.insufficientBalance,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
