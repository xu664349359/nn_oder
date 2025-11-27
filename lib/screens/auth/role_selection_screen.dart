import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _nicknameController = TextEditingController();
  UserRole? _selectedRole;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      await context.read<AuthProvider>().register(
        _nicknameController.text.trim(),
        _selectedRole!,
      );
      if (mounted) {
        // Router redirect will handle navigation
        // But we might want to go to binding screen if no partner
        // The router redirect logic checks for partner? No, it checks for role.
        // We should add logic to go to binding if partnerId is null.
        // For now, let's just let the router handle it.
        // Wait, the router logic I wrote:
        // if (isLoggedIn) { if (role == chef) ... else ... }
        // It doesn't check for binding.
        // I should update router to check for binding if I want to force it.
        // The user requirement says "Binding completed then enter home page".
        // So I should add a check in router or manually navigate to binding.
        // Let's manually navigate to binding after register for now, or update router.
        // Updating router is better for persistence.
      }
    } else if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Who are you?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: 'Nickname',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a nickname';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        title: 'Chef',
                        subtitle: 'I cook with love',
                        icon: Icons.restaurant_menu,
                        isSelected: _selectedRole == UserRole.chef,
                        onTap: () => setState(() => _selectedRole = UserRole.chef),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCard(
                        title: 'Foodie',
                        subtitle: 'I eat with joy',
                        icon: Icons.dining,
                        isSelected: _selectedRole == UserRole.foodie,
                        onTap: () => setState(() => _selectedRole = UserRole.foodie),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: context.watch<AuthProvider>().isLoading ? null : _register,
                  child: context.watch<AuthProvider>().isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Start My Kitchen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
