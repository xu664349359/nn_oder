import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/menu_card.dart';

class FoodieHomeScreen extends StatefulWidget {
  const FoodieHomeScreen({super.key});

  @override
  State<FoodieHomeScreen> createState() => _FoodieHomeScreenState();
}

class _FoodieHomeScreenState extends State<FoodieHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final dataProvider = context.watch<DataProvider>();
    final menuItems = dataProvider.menuItems;
    final intimacy = dataProvider.intimacy;

    // Simple recommendation logic: just pick the first one or random
    final recommendedItem = menuItems.isNotEmpty ? menuItems.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Hi, ${user?.nickname ?? 'Foodie'}'),
            Text(
              'Intimacy: ${intimacy?.value ?? 0} ❤️',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Today\'s Special',
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
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Chef hasn\'t added any dishes yet!')),
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/foodie/menu'),
                  child: const Text('See All'),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/foodie/menu');
          if (index == 2) context.push('/foodie/orders');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
        ],
      ),
    );
  }
}
