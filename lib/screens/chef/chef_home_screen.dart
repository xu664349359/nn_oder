import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/order_card.dart';

class ChefHomeScreen extends StatefulWidget {
  const ChefHomeScreen({super.key});

  @override
  State<ChefHomeScreen> createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends State<ChefHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().fetchOrders();
      context.read<DataProvider>().fetchIntimacy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final dataProvider = context.watch<DataProvider>();
    final orders = dataProvider.orders;
    final intimacy = dataProvider.intimacy;

    // Filter orders (in real app, backend filters)
    // Here we show all orders for simplicity or filter by chefId if we had it in local user
    // But mock service returns all orders.
    
    final pendingOrders = orders.where((o) => o.status == OrderStatus.pending).toList();
    final cookingOrders = orders.where((o) => o.status == OrderStatus.cooking).toList();
    final completedOrders = orders.where((o) => o.status == OrderStatus.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Chef Dashboard'),
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
      body: DefaultTabController(
        length: 3,
        child: Column(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/chef/menu');
          if (index == 2) context.push('/chef/intimacy');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Intimacy'),
        ],
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
