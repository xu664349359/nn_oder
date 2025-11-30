import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../models/menu_model.dart';
import '../../providers/data_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/menu_card.dart';
import 'recipe_editor_screen.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = context.watch<DataProvider>().menuItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.menuManagement),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Card(
                color: AppColors.warmPink,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.foodieStatus,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red),
                              const SizedBox(height: 4),
                              Text(
                                '${context.watch<DataProvider>().intimacy?.score ?? 0}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(AppLocalizations.of(context)!.intimacy),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.orange),
                              const SizedBox(height: 4),
                              Text(AppLocalizations.of(context)!.hungry, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(AppLocalizations.of(context)!.mood),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return MenuCard(
                    menuItem: menuItems[index],
                    isChef: true,
                    onTap: () {
                      // Navigate to recipe editor
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeEditorScreen(menuItem: menuItems[index]),
                        ),
                      );
                    },
                  );
                },
                childCount: menuItems.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () => _showAddMenuDialog(context),
          child: const Icon(Icons.add),
        ),
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
  
  String? _selectedImagePath;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      
      try {
        final menuItemId = const Uuid().v4();
        String imageUrl = '';
        
        // Upload image if selected
        if (_selectedImagePath != null) {
          final supabaseService = SupabaseService();
          imageUrl = await supabaseService.uploadMenuImage(_selectedImagePath!, menuItemId);
        }
        
        final newItem = MenuItem(
          id: menuItemId,
          name: _nameController.text,
          description: _descController.text,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : 'assets/images/placeholder_food.png',
          intimacyPrice: int.parse(_priceController.text),
          ingredients: ['Love'], // Simplified
          steps: [RecipeStep(stepNumber: 1, description: 'Cook with love')], // Simplified
        );

        if (!mounted) return;
        await context.read<DataProvider>().addMenuItem(newItem);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
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
              AppLocalizations.of(context)!.addNewDish,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.tapToAddImage, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dishName),
              validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
              validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.intimacyPrice),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.required : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.addToMenu),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
