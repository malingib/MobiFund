import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../services/supabase_service.dart';
import '../services/local_db.dart';
import 'profile_screen.dart';
import 'module_management_screen.dart';
import 'help_center_screen.dart';
import 'bug_report_screen.dart';
import 'billing_tiers_screen.dart';
import 'privacy_security_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import '../widgets/shared_widgets.dart';
import '../services/push_notification_service.dart';
import '../services/preferences_state.dart';
import '../services/sms_service.dart';
import 'super_admin_mpesa_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final prefs = context.watch<PreferencesState>();

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.softGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account
            SectionCard(
              title: '',
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Edit your personal information',
                    onTap: () => _navigateToProfile(context),
                  ),
                  _settingsTile(
                    icon: Icons.apps_outlined,
                    title: 'Modules',
                    subtitle: 'Manage activated features',
                    onTap: () => _navigateToModules(context),
                  ),
                  _settingsTile(
                    icon: Icons.security,
                    title: 'Privacy & Security',
                    subtitle: 'Password, biometric login',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySecurityScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Billing
            SectionCard(
              title: '',
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.credit_card,
                    title: 'Plan & Billing',
                    subtitle: 'Manage your subscription',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (state.currentOrg?.tier.name ?? 'Free').toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const BillingTiersScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // App Settings
            SectionCard(
              title: '',
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts for contributions and loans',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) async {
                        setState(() => _notificationsEnabled = val);
                        if (val) {
                          await PushNotificationService().registerDeviceToken();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Notifications Enabled'),
                                  backgroundColor: AppTheme.success),
                            );
                          }
                        } else {
                          await PushNotificationService().removeDeviceToken();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Notifications Disabled'),
                                  backgroundColor: AppTheme.textLight),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  _settingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Theme and display settings',
                    onTap: () => _showThemeDialog(context),
                  ),
                  _settingsTile(
                    icon: Icons.language,
                    title: 'Language & Region',
                    subtitle:
                        '${prefs.locale.languageCode.toUpperCase()}${prefs.locale.countryCode != null ? ' (${prefs.locale.countryCode})' : ''}',
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _settingsTile(
                    icon: Icons.cloud_sync_outlined,
                    title: 'Data & Sync',
                    subtitle: 'Manage cached data and sync settings',
                    onTap: () => _showStorageDialog(context, state),
                  ),
                  _settingsTile(
                    icon: Icons.sms_outlined,
                    title: 'SMS Settings',
                    subtitle: 'Configure Mobiwave API key & sender ID',
                    onTap: () => _showSmsSettingsDialog(context),
                  ),
                  if (state.isPlatformAdmin) ...[
                    _settingsTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Platform Dashboard',
                      subtitle: 'Cross-org reporting & support mode',
                      onTap: () => Navigator.of(context).pushNamed('/platform'),
                    ),
                    _settingsTile(
                      icon: Icons.payment_outlined,
                      title: 'Super Admin: M-Pesa',
                      subtitle: 'Configure Daraja credentials (encrypted)',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SuperAdminMpesaScreen(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Support
            SectionCard(
              title: '',
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    subtitle: 'FAQs and guides',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen()),
                    ),
                  ),
                  _settingsTile(
                    icon: Icons.chat_outlined,
                    title: 'Contact Us',
                    subtitle: 'Get in touch',
                    onTap: () => _showContactDialog(context),
                  ),
                  _settingsTile(
                    icon: Icons.bug_report_outlined,
                    title: 'Report a Bug',
                    subtitle: 'Help us improve',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const BugReportScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // About
            SectionCard(
              title: '',
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.info_outline,
                    title: 'About Mobifund',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAboutDialog(context),
                  ),
                  _settingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsOfServiceScreen(),
                      ),
                    ),
                  ),
                  _settingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we protect your data',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Sign out — quiet TextButton, not a screaming-red CTA.
            // Destructive actions should be discoverable, not loud.
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: AppTheme.danger, size: 18),
                label: const Text(
                  'Sign out',
                  style: TextStyle(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Delete Account
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(context),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    String? title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    assert(title != null, '_settingsTile requires a title');
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title!,
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
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: AppTheme.textLight),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToModules(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ModuleManagementScreen()),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final prefs = context.read<PreferencesState>();
    final current = prefs.themeMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(
                ctx,
                'Light',
                Icons.light_mode,
                current == ThemeMode.light,
                () => prefs.setThemeMode(ThemeMode.light)),
            const SizedBox(height: 8),
            _themeOption(
                ctx,
                'Dark',
                Icons.dark_mode,
                current == ThemeMode.dark,
                () => prefs.setThemeMode(ThemeMode.dark)),
            const SizedBox(height: 8),
            _themeOption(
                ctx,
                'System',
                Icons.settings_suggest,
                current == ThemeMode.system,
                () => prefs.setThemeMode(ThemeMode.system)),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
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

  void _showSmsSettingsDialog(BuildContext context) {
    final apiCtrl = TextEditingController();
    final senderCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: const Text('SMS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: apiCtrl,
              decoration: const InputDecoration(
                labelText: 'Mobiwave API Key',
                hintText: 'Paste your API key',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: senderCtrl,
              decoration: const InputDecoration(
                labelText: 'Sender ID (optional, max 11 chars)',
                hintText: 'Mobifund',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              apiCtrl.dispose();
              senderCtrl.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await SmsService.saveCredentials(
                  apiKey: apiCtrl.text,
                  senderId: senderCtrl.text,
                );
                apiCtrl.dispose();
                senderCtrl.dispose();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SMS settings saved'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: const Text('Data & Sync'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.isOnline
                  ? 'Your data is synced with the cloud. Clear cache to force a fresh sync.'
                  : 'You\'re offline. Data is stored locally and will sync when connected.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _storageInfo('Members', '${state.members.length}')),
                const SizedBox(width: 8),
                Expanded(
                    child: _storageInfo(
                        'Contributions', '${state.contributions.length}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child:
                        _storageInfo('Expenses', '${state.expenses.length}')),
                const SizedBox(width: 8),
                Expanded(child: _storageInfo('Loans', '${state.loans.length}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final counts = await LocalDb.clearCache();
                final total = counts.values.fold(0, (sum, c) => sum + c);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Cache cleared — $total records queued for re-sync'),
                    backgroundColor: AppTheme.success,
                  ),
                );
                // Trigger a fresh sync
                await state.syncNow();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to clear cache: $e'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  Widget _storageInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Mobifund',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.account_balance_wallet, color: Colors.white),
      ),
      children: [
        const Text('Group Finance Made Simple'),
        const SizedBox(height: 16),
        const Text('© 2026 Mobiwave Innovations Limited'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppTheme.warning),
            ),
            const SizedBox(width: 12),
            const Text('Log Out'),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Use Supabase signOut as single source of truth
              await SupabaseService().signOut();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (r) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever, color: AppTheme.danger),
            ),
            const SizedBox(width: 12),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your local data will be permanently deleted. Your organizations and data on the server will remain accessible to other members.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Clear local data
                await LocalDb.clearAllData();
                // Sign out from Supabase
                await SupabaseService().signOut();
                if (!context.mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (r) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Local data deleted. You have been signed out.'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete account: $e'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contactRow(Icons.email_outlined, 'support@mobifund.co.ke'),
            const SizedBox(height: 12),
            _contactRow(Icons.phone_outlined, '+254 700 000 000'),
            const SizedBox(height: 12),
            _contactRow(Icons.language, 'www.mobifund.co.ke'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
