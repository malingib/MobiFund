import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/about_screen.dart';
import 'screens/module_management_screen.dart';
import 'services/app_state.dart';
import 'services/supabase_service.dart';
import 'services/preferences_state.dart';
import 'screens/enhanced_dashboard_screen.dart';
import 'screens/members_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/modules_hub_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/org_switcher.dart';
import 'models/models.dart';
import 'screens/platform/platform_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional - will use fallback values if not present)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file not found, using fallback values from SupabaseService
    debugPrint('Note: .env file not found, using default/supabase credentials');
  }

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase with credentials from .env
  await Supabase.initialize(
    url: SupabaseService.supabaseUrl,
    anonKey: SupabaseService.supabaseAnonKey,
  );

  final prefsState = PreferencesState();
  await prefsState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider.value(value: prefsState),
      ],
      child: const ChamaApp(),
    ),
  );
}

class ChamaApp extends StatelessWidget {
  const ChamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesState>();
    return MaterialApp(
      title: 'Mobifund',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: prefs.themeMode,
      locale: prefs.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainShell(),
        '/platform': (context) => const PlatformShell(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Index mapping:
  // 0 = Dashboard
  // 1 = Members
  // 2 = Center FAB (Quick Actions)
  // 3 = Expenses
  // 4 = Settings
  // Profile is accessed from Settings or quick actions

  final List<Widget> _screens = const [
    EnhancedDashboardScreen(),
    MembersScreen(),
    ModulesHubScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Members',
    'Modules',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onCenterTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: AppTheme.headline,
            ),
            const SizedBox(height: 20),
            // Screen mapping:
            // 0 = Dashboard
            // 1 = Members
            // 2 = Modules Hub (also has Contributions and Expenses)
            // 3 = Settings
            Row(
              children: [
                Expanded(
                  child: _quickActionItem(
                    ctx,
                    Icons.person_add_outlined,
                    'Add Member',
                    AppTheme.primary,
                    1, // → Members tab
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionItem(
                    ctx,
                    Icons.add_circle_outline,
                    'Contributions',
                    AppTheme.success,
                    2, // → Modules Hub (contains Contributions)
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionItem(
                    ctx,
                    Icons.remove_circle_outline,
                    'Expenses',
                    AppTheme.danger,
                    2, // → Modules Hub (contains Expenses)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _quickActionItem(
                    ctx,
                    Icons.person_outline,
                    'Profile',
                    AppTheme.accent,
                    3, // → Settings tab
                  ),
                ),
                Expanded(
                  child: _quickActionItem(
                    ctx,
                    Icons.analytics_outlined,
                    'Reports',
                    AppTheme.primary,
                    0, // In Dashboard
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickActionItem(
                    ctx,
                    Icons.settings_outlined,
                    'Settings',
                    AppTheme.info,
                    3, // Settings Tab
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _quickActionItem(
    BuildContext ctx,
    IconData icon,
    String label,
    Color color,
    int tabIndex,
  ) {
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        Navigator.pop(ctx);
        setState(() => _currentIndex = tabIndex);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTheme.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: OrganizationSwitcher(),
        ),
        title: Text(
          _titles[_currentIndex],
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          // Module management (admin only)
          if (state.hasPermission(UserRole.admin))
            IconButton(
              icon:
                  const Icon(Icons.apps_outlined, color: AppTheme.textPrimary),
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ModuleManagementScreen()),
                );
              },
              tooltip: 'Modules',
            ),
          // Online/offline indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: state.isOnline
                  ? AppTheme.success.withValues(alpha: 0.1)
                  : AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.isOnline
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : AppTheme.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.isOnline ? AppTheme.success : AppTheme.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  state.isOnline ? 'Online' : 'Offline',
                  style: AppTheme.caption.copyWith(
                    color: state.isOnline ? AppTheme.success : AppTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Manual sync button
          if (state.isOnline)
            IconButton(
              icon: state.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.sync, color: AppTheme.primary),
              onPressed: state.isSyncing
                  ? null
                  : () {
                      AppHaptics.selection();
                      state.syncNow();
                    },
              tooltip: 'Sync',
            ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
            onPressed: () {
              AppHaptics.selection();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
            tooltip: 'About',
          ),
          if (state.isInSupportMode)
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: AppTheme.warning),
              tooltip: 'Exit support mode (local)',
              onPressed: () {
                AppHaptics.selection();
                state.exitSupportMode();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.isInSupportMode)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, color: AppTheme.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Support Mode active • Expires at ${state.supportExpiresAt?.toLocal().toString().split(".").first}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onCenterTap: _onCenterTap,
      ),
    );
  }
}
