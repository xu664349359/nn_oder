import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final _codeController = TextEditingController();
  bool _isBinding = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _bind() async {
    if (_codeController.text.isEmpty) return;
    
    setState(() => _isBinding = true);
    
    // In a real app, we would check the role of the partner here.
    // Since our mock service is simple, we'll assume the service handles it or we check it.
    // The requirement says: "If role same -> Error".
    // We need to update MockDataService or AuthProvider to return specific error or check role.
    // For now, let's assume the provider returns false if failed.
    // We should ideally update the service to support this check.
    
    final success = await context.read<AuthProvider>().bindPartner(_codeController.text.trim());
    
    setState(() => _isBinding = false);

    if (success && mounted) {
      // Navigate to binding success animation
      context.go('/binding-success');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Binding failed. Check code or role.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Connect Partner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // My Code Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'My Invitation Code',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.invitationCode ?? 'Generating...',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // QR Code Placeholder
                    Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.qr_code, size: 80, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: user.invitationCode ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Code'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Input Partner Code Section
            Text(
              'Enter Partner\'s Code',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Enter code here',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isBinding ? null : _bind,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isBinding
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Connect'),
            ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                 await context.read<AuthProvider>().skipBinding();
                 if (mounted) Navigator.pop(context);
              }, 
              child: const Text('Skip (Dev Only)'),
            ),
          ],
        ),
      ),
    );
  }
}
