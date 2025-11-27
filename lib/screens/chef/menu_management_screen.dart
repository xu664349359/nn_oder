import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants.dart';
import '../../models/menu_model.dart';
import '../../providers/data_provider.dart';
import '../../widgets/menu_card.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = context.watch<DataProvider>().menuItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
      ),
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
            isChef: true,
            onTap: () {
              // Edit logic could go here
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenuDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddMenuForm(),
    );
  }
}

class _AddMenuForm extends StatefulWidget {
  const _AddMenuForm();

  @override
  State<_AddMenuForm> createState() => _AddMenuFormState();
}

class _AddMenuFormState extends State<_AddMenuForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newItem = MenuItem(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descController.text,
        imageUrl: 'assets/images/placeholder_food.png', // Placeholder
        intimacyPrice: int.parse(_priceController.text),
        ingredients: ['Love'], // Simplified
        steps: [RecipeStep(description: 'Cook with love')], // Simplified
      );

      context.read<DataProvider>().addMenuItem(newItem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add New Dish',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Dish Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Intimacy Price'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add to Menu'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
