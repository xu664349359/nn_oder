import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';
import '../../widgets/menu_card.dart';

class MenuBrowserScreen extends StatelessWidget {
  const MenuBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = context.watch<DataProvider>().menuItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Full Menu')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return MenuCard(
            menuItem: menuItems[index],
            onTap: () => context.push('/foodie/menu/detail', extra: menuItems[index]),
          );
        },
      ),
    );
  }
}
