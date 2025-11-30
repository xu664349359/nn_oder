import 'package:flutter/material.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/menu_card.dart';
import 'order_history_screen.dart';
import '../chef/intimacy_management_screen.dart';
import '../moments/moments_screen.dart';
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

class _FoodieHomeContent extends StatelessWidget {
  const _FoodieHomeContent();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final dataProvider = context.watch<DataProvider>();
    final menuItems = dataProvider.menuItems;
    final intimacy = dataProvider.intimacy;
    final l10n = AppLocalizations.of(context)!;

    // Simple recommendation logic: just pick the first one or random
    final recommendedItem = menuItems.isNotEmpty ? menuItems.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Hi, ${user?.nickname ?? l10n.foodie}'),
            Text(
              '${l10n.intimacy}: ${intimacy?.score ?? 0} ❤️',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DataProvider>().fetchMenu();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.todaysSpecial,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (recommendedItem != null)
                SizedBox(
                  height: 250,
                  child: MenuCard(
                    menuItem: recommendedItem,
                    onTap: () => context.push('/foodie/menu/detail', extra: recommendedItem),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(l10n.noDishes)),
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.menu,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/foodie/menu'),
                    child: Text(l10n.seeAll),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: menuItems.length > 4 ? 4 : menuItems.length,
                itemBuilder: (context, index) {
                  return MenuCard(
                    menuItem: menuItems[index],
                    onTap: () => context.push('/foodie/menu/detail', extra: menuItems[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
