import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/menu_card.dart';
import 'order_history_screen.dart';
import '../chef/intimacy_management_screen.dart';
import '../moments/moments_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/modern_bottom_navigation.dart';

class FoodieHomeScreen extends StatefulWidget {
  const FoodieHomeScreen({super.key});

  @override
  State<FoodieHomeScreen> createState() => _FoodieHomeScreenState();
}

class _FoodieHomeScreenState extends State<FoodieHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadInitialData();
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
    final pages = [
      const _FoodieHomeContent(),   // Home
      const OrderHistoryScreen(),   // Orders
      const IntimacyManagementScreen(), // Intimacy
      const MomentsScreen(),        // Moments
      const ProfileScreen(),        // Profile
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: l10n.orders),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: l10n.intimacy),
          BottomNavigationBarItem(icon: const Icon(Icons.camera), label: l10n.moments),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profile),
        ],
      ),
    );
  }
}

class _FoodieHomeContent extends StatefulWidget {
  const _FoodieHomeContent();

  @override
  State<_FoodieHomeContent> createState() => _FoodieHomeContentState();
}

class _FoodieHomeContentState extends State<_FoodieHomeContent> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Meat', 'Veggie', 'Soup', 'Dessert', 'Drinks']; // Mock categories

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final dataProvider = context.watch<DataProvider>();
    final cartProvider = context.watch<CartProvider>();
    final menuItems = dataProvider.menuItems;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Warm "Healing" background
      body: CustomScrollView(
        slivers: [
          // 1. Warm Illustration Header (SliverAppBar)
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFFFF8F0),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Warm textured background/image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFFE0B2), // Light Amber
                          const Color(0xFFFFF8F0),
                        ],
                      ),
                    ),
                  ),
                  // Illustration (Placeholder for now, using Icon/Pattern)
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.lunch_dining_rounded,
                      size: 200,
                      color: Colors.orange.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hungry, ${user?.nickname ?? l10n.foodie}?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037), // Warm brown
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(),
                        Text(
                          l10n.startDeliciousMoments,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF5D4037).withOpacity(0.7),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(),
                      ],
                    ),
                  ),
                ],
              ),
              title: Text(
                'Love Kitchen',
                style: TextStyle(
                  color: const Color(0xFF5D4037).withOpacity(_isCollapsed(context) ? 1.0 : 0.0), // Fade in title on scroll
                ),
              ),
              centerTitle: true,
            ),
            actions: [
               Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF5D4037)),
                    onPressed: () => context.push('/foodie/cart'),
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 2. Category Navigation Bar (Sticky)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverCategoryHeaderDelegate(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (index) {
                setState(() => _selectedCategoryIndex = index);
                // In real app, filter menuItems here
              },
            ),
          ),

          // 3. Card-Style Dish Stream (Masonry/Staggered Grid)
          if (menuItems.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ramen_dining, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(l10n.noDishes, style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childCount: menuItems.length,
                itemBuilder: (context, index) {
                  return MenuCard(
                    menuItem: menuItems[index],
                    onTap: () => context.push('/foodie/menu/detail', extra: menuItems[index]),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: (index * 100).ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack) // "Pop" slide
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack); // subtle scale bounce
                },
              ),
            ),
            
             const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }

  bool _isCollapsed(BuildContext context) {
    // Helper to detect if app bar is collapsed (roughly) based on scroll offset or just use visibility
    // Since we can't easily access scroll offset here without a controller, relying on Opacity logic in widget tree or strictly style choice.
    // simpler: Always show title if collapsed, but FlexibleSpaceBar handles title opacity automatically if set in title. 
    // Actually FlexibleSpaceBar title is typically always visible or fades out background. 
    // To fade IN title on collapse, we'd need a ScrollController. For simplicity, just letting standard behavior work or always show.
    return false; 
  }
}

class _SliverCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  _SliverCategoryHeaderDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      color: const Color(0xFFFFF8F0), // Match background
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: AnimatedContainer(
              duration: 300.ms,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFB74D) : Colors.white, // Orange vs White
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected 
                  ? [BoxShadow(color: const Color(0xFFFFB74D).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF5D4037),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 74.0; 

  @override
  double get minExtent => 74.0;

  @override
  bool shouldRebuild(covariant _SliverCategoryHeaderDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex;
  }
}
