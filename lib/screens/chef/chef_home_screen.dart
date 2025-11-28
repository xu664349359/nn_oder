import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/order_card.dart';
import 'menu_management_screen.dart';
import 'intimacy_management_screen.dart';
import '../moments/moments_screen.dart';
import '../profile/profile_screen.dart';

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
    final pages = [
      const MenuManagementScreen(), // Home (Menu + Status)
      const _ChefOrdersPage(),      // Orders
      const IntimacyManagementScreen(), // Intimacy
      const MomentsScreen(),        // Moments
      const ProfileScreen(),        // Profile
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Intimacy'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Moments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
    
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
    final cookingOrders = orders.where((o) => o.status == OrderStatus.cooking).toList();
    final completedOrders = orders.where((o) => o.status == OrderStatus.completed).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: Column(
          children: [
            Container(
              color: AppColors.surface,
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Pending (${pendingOrders.length})'),
                  Tab(text: 'Cooking (${cookingOrders.length})'),
                  Tab(text: 'Done (${completedOrders.length})'),
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
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No orders here',
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
        );
      },
    );
  }
}
