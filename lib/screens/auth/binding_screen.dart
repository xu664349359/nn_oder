import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (_codeController.text.isEmpty) return;
    
    setState(() => _isBinding = true);
    final success = await context.read<AuthProvider>().bindPartner(_codeController.text.trim());
    setState(() => _isBinding = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connected)),
      );
      // Router will handle redirect
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connectionFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final l10n = AppLocalizations.of(context)!;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isChef = user.role == UserRole.chef;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.connectPartner),

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
                  l10n.yourCode,
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
                Text(
                  l10n.shareCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ] else ...[
                Text(
                  l10n.enterCode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: l10n.enterCodeHint,
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isBinding ? null : _bindPartner,
                  child: _isBinding
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.connect),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
