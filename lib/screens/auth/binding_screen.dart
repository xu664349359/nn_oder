import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class BindingScreen extends StatefulWidget {
  const BindingScreen({super.key});

  @override
  State<BindingScreen> createState() => _BindingScreenState();
}

class _BindingScreenState extends State<BindingScreen> {
  final _codeController = TextEditingController();
  bool _isBinding = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _bindPartner() async {
    if (_codeController.text.isEmpty) return;
    
    setState(() => _isBinding = true);
    final success = await context.read<AuthProvider>().bindPartner(_codeController.text.trim());
    setState(() => _isBinding = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected with your partner! ❤️')),
      );
      // Router will handle redirect
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code or connection failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isChef = user.role == UserRole.chef;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Partner'),
        actions: [
          TextButton(
            onPressed: () async {
               await context.read<AuthProvider>().skipBinding();
               // Router will handle redirect now that partnerId is set
            }, 
            child: const Text('Skip (Dev)'),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 100, color: AppColors.primary)
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1), curve: Curves.easeInOut)
                  .then()
                  .scale(duration: 1.seconds, begin: const Offset(1.1, 1.1), end: const Offset(1, 1), curve: Curves.easeInOut),
              const SizedBox(height: 32),
              if (isChef) ...[
                Text(
                  'Your Invitation Code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: SelectableText(
                    user.invitationCode ?? 'ERROR',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share this code with your Foodie to connect!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ] else ...[
                Text(
                  'Enter Invitation Code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Enter code from Chef',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isBinding ? null : _bindPartner,
                  child: _isBinding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Connect'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
