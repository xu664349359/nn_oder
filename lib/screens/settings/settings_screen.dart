import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nn_oder/l10n/generated/app_localizations.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/modern_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _customAvatarPath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nicknameController.text = user.nickname;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getDefaultAvatar() {
    final user = context.read<AuthProvider>().currentUser;
    if (user?.role == UserRole.chef) {
      return '👨‍🍳';
    } else if (user?.role == UserRole.foodie) {
      return '🐛';
    }
    return '👤';
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _customAvatarPath = image.path;
      });
    }
  }

  Future<void> _saveChanges() async {
    // TODO: Implement actual save logic
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved! (Mock)')),
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final l10n = AppLocalizations.of(context)!;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveChanges,
              child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Profile Header
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _customAvatarPath != null
                              ? Image.file(File(_customAvatarPath!), fit: BoxFit.cover)
                              : user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                  ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                                  : null,
                        ),
                      ),
                      if (_customAvatarPath == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty))
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              _getDefaultAvatar(),
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      if (_isEditing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        controller: _nicknameController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.nickname,
                        ),
                      ),
                    )
                  else
                    Text(
                      user.nickname,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role == UserRole.chef ? '${l10n.chef} 👨‍🍳' : '${l10n.foodie} 🐛',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (!_isEditing) ...[
              // Settings Groups
              _buildSettingsGroup([
                _buildSettingsItem(
                  icon: Icons.person_outline,
                  iconColor: Colors.blue,
                  title: l10n.editProfile,
                  onTap: () => setState(() => _isEditing = true),
                ),
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: l10n.notifications,
                  trailing: Switch.adaptive(
                    value: true,
                    onChanged: (val) {},
                    activeColor: AppColors.primary,
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.language,
                  iconColor: Colors.purple,
                  title: l10n.language,
                  value: Localizations.localeOf(context).languageCode == 'zh' ? '中文' : 'English',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('English'),
                              trailing: Localizations.localeOf(context).languageCode == 'en'
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                context.read<LocaleProvider>().setLocale(const Locale('en'));
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('中文'),
                              trailing: Localizations.localeOf(context).languageCode == 'zh'
                                  ? const Icon(Icons.check, color: AppColors.primary)
                                  : null,
                              onTap: () {
                                context.read<LocaleProvider>().setLocale(const Locale('zh'));
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.black87,
                  title: l10n.darkMode,
                  trailing: Switch.adaptive(
                    value: false,
                    onChanged: (val) {},
                    activeColor: AppColors.primary,
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _buildSettingsGroup([
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  iconColor: Colors.teal,
                  title: l10n.about,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: l10n.appTitle,
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.favorite, color: AppColors.primary),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.link_off,
                  iconColor: Colors.redAccent,
                  title: l10n.unbindPartner,
                  isDestructive: true,
                  onTap: () async {
                    final confirm = await ModernDialog.show<bool>(
                      context: context,
                      title: l10n.unbindPartner,
                      description: 'This will remove your connection with your partner. Are you sure?',
                      icon: Icons.link_off,
                      iconColor: Colors.red,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(l10n.confirm),
                        ),
                      ],
                    );

                    if (confirm == true) {
                      // TODO: Implement actual unbind logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unbind feature coming soon')),
                      );
                    }
                  },
                ),
              ]),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () async {
                  final confirm = await ModernDialog.show<bool>(
                    context: context,
                    title: l10n.logout,
                    description: 'Are you sure you want to log out?',
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.confirm),
                      ),
                    ],
                  );

                  if (confirm == true) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  l10n.logout,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : AppColors.textPrimary,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
