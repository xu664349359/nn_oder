import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class IntimacyManagementScreen extends StatefulWidget {
  const IntimacyManagementScreen({super.key});

  @override
  State<IntimacyManagementScreen> createState() => _IntimacyManagementScreenState();
}

class _IntimacyManagementScreenState extends State<IntimacyManagementScreen> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _updateIntimacy(int change) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(change > 0 ? AppLocalizations.of(context)!.addLove : AppLocalizations.of(context)!.reduceLove),
        content: TextField(
          controller: _reasonController,
          decoration: InputDecoration(hintText: AppLocalizations.of(context)!.reasonOptional),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().updateIntimacy(
                change,
                _reasonController.text.isEmpty ? (change > 0 ? AppLocalizations.of(context)!.bonus : AppLocalizations.of(context)!.penalty) : _reasonController.text,
              );
              _reasonController.clear();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final intimacy = context.watch<DataProvider>().intimacy;
    final history = intimacy?.history ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.intimacyCenter)),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              gradient: AppColors.romanticGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  '${intimacy?.score ?? 0}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.currentIntimacy,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                if (context.read<AuthProvider>().currentUser?.role == UserRole.chef)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _updateIntimacy(10),
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.add10),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _updateIntimacy(-5),
                        icon: const Icon(Icons.remove),
                        label: Text(AppLocalizations.of(context)!.reduce5),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                final isPositive = record.change > 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPositive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    child: Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? AppColors.success : AppColors.error,
                      size: 20,
                    ),
                  ),
                  title: Text(record.reason),
                  subtitle: Text(DateFormat('MMM d, h:mm a').format(record.timestamp)),
                  trailing: Text(
                    '${isPositive ? '+' : ''}${record.change}',
                    style: TextStyle(
                      color: isPositive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
