import 'package:flutter/material.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/order_card.dart';
import 'menu_management_screen.dart';
import 'recipe_editor_screen.dart';
import 'intimacy_management_screen.dart';
import '../moments/moments_screen.dart';
import '../moments/moments_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/modern_bottom_navigation.dart';

class ChefHomeScreen extends StatefulWidget {
  const ChefHomeScreen({super.key});

  @override
  State<ChefHomeScreen> createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends State<ChefHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchOrders();
      context.read<DataProvider>().fetchIntimacy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      const MenuManagementScreen(), // Home (Menu + Status)
      const _ChefOrdersPage(),      // Orders
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

class _ChefOrdersPage extends StatelessWidget {
  const _ChefOrdersPage();

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final orders = dataProvider.orders;
    final l10n = AppLocalizations.of(context)!;
    
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
    final cookingOrders = orders.where((o) => o.status == OrderStatus.cooking).toList();
    final completedOrders = orders.where((o) => o.status == OrderStatus.completed).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.orders)),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(text: '${l10n.pending} (${pendingOrders.length})'),
                  Tab(text: '${l10n.cooking} (${cookingOrders.length})'),
                  Tab(text: '${l10n.done} (${completedOrders.length})'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OrderList(orders: pendingOrders, isChef: true),
                  _OrderList(orders: cookingOrders, isChef: true),
                  _OrderList(orders: completedOrders, isChef: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final bool isChef;

  const _OrderList({required this.orders, required this.isChef});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              l10n.noOrders,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          isChef: isChef,
          onStatusChange: () {
            final nextStatus = order.status == OrderStatus.pending
                ? OrderStatus.cooking
                : OrderStatus.completed;
            context.read<DataProvider>().updateOrderStatus(order.id, nextStatus);
          },
          onViewRecipe: () {
            final menuItems = context.read<DataProvider>().menuItems;
            try {
              final menuItem = menuItems.firstWhere((item) => item.id == order.menuItemId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeEditorScreen(menuItem: menuItem),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.recipeNotFound)),
              );
            }
          },
        );
      },
    );
  }
}
