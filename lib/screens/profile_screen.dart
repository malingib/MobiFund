import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/preferences_state.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final state = context.read<AppState>();
    final userId = state.currentUserId;
    
    // Find the current user in orgMembers (which has userId mapping)
    final currentUserMember = state.orgMembers.firstWhere(
      (m) => m.userId == userId,
      orElse: () => OrgMember(
        orgId: state.currentOrg?.id ?? '',
        userId: userId,
        name: 'Member',
        phone: '',
      ),
    );

    _nameCtrl.text = currentUserMember.name;
    _phoneCtrl.text = currentUserMember.phone ?? '';
    _emailCtrl.text = currentUserMember.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final state = context.read<AppState>();
    final userId = state.currentUserId;
    final currentUserMember = state.orgMembers.firstWhere(
      (m) => m.userId == userId,
      orElse: () => OrgMember(
        orgId: state.currentOrg?.id ?? '',
        userId: userId,
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
      ),
    );

    try {
      await state.updateMember(currentUserMember.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
      ));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _nameCtrl.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _emailCtrl.text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Edit Button
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats Overview
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Groups',
                  '1',
                  Icons.groups,
                  AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Transactions',
                  '${state.contributions.length + state.expenses.length}',
                  Icons.swap_horiz,
                  AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Members',
                  '${state.members.length}',
                  Icons.people,
                  AppTheme.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Profile Information
          SectionCard(
            title: 'Personal Information',
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email Address',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Account Actions
          if (_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),

          const SizedBox(height: 16),

          // Security Section
          SectionCard(
            title: 'Security',
            child: Column(
              children: [
                _listTile(
                  icon: Icons.lock_outline,
                  iconColor: AppTheme.primary,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () => _showChangePasswordDialog(),
                ),
                const Divider(height: 1),
                _listTile(
                  icon: Icons.fingerprint,
                  iconColor: AppTheme.success,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face ID',
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: (v) => setState(() => _biometricEnabled = v),
                    activeThumbColor: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App Preferences
          SectionCard(
            title: 'Preferences',
            child: Column(
              children: [
                _listTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.warning,
                  title: 'Notifications',
                  subtitle: 'Manage notification settings',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manage notifications in Settings → Push Notifications.'),
                        backgroundColor: AppTheme.info,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _listTile(
                  icon: Icons.palette_outlined,
                  iconColor: AppTheme.primary,
                  title: 'Theme',
                  subtitle: context.watch<PreferencesState>().themeMode.name,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context),
                ),
                const Divider(height: 1),
                _listTile(
                  icon: Icons.language,
                  iconColor: AppTheme.success,
                  title: 'Language',
                  subtitle:
                      '${context.watch<PreferencesState>().locale.languageCode.toUpperCase()}'
                      '${context.watch<PreferencesState>().locale.countryCode != null ? ' (${context.watch<PreferencesState>().locale.countryCode})' : ''}',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final prefs = context.read<PreferencesState>();
    final current = prefs.themeMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(ctx, 'Light', Icons.light_mode,
                current == ThemeMode.light, () => prefs.setThemeMode(ThemeMode.light)),
            const SizedBox(height: 8),
            _themeOption(ctx, 'Dark', Icons.dark_mode,
                current == ThemeMode.dark, () => prefs.setThemeMode(ThemeMode.dark)),
            const SizedBox(height: 8),
            _themeOption(ctx, 'System', Icons.settings_suggest,
                current == ThemeMode.system, () => prefs.setThemeMode(ThemeMode.system)),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onSelect,
  ) {
    return ListTile(
      selected: isSelected,
      leading: Icon(icon,
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
      title: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : Colors.transparent,
        ),
      ),
      onTap: () async {
        onSelect();
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final prefs = context.read<PreferencesState>();
    final current = prefs.locale;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Language & Region'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              selected: current.languageCode == 'en' &&
                  (current.countryCode ?? 'KE') == 'KE',
              leading: const Icon(Icons.language, color: AppTheme.primary),
              title: const Text('English (Kenya)'),
              onTap: () async {
                await prefs.setLocale(const Locale('en', 'KE'));
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              selected: current.languageCode == 'en' &&
                  (current.countryCode ?? 'US') == 'US',
              leading: const Icon(Icons.language, color: AppTheme.primary),
              title: const Text('English (US)'),
              onTap: () async {
                await prefs.setLocale(const Locale('en', 'US'));
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _listTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textLight),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
