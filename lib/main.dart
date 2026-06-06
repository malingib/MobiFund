import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/models.dart';
import 'screens/about_screen.dart';
import 'screens/enhanced_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/members_screen.dart';
import 'screens/module_management_screen.dart';
import 'screens/modules_hub_screen.dart';
import 'screens/platform/platform_shell.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/app_state.dart';
import 'services/preferences_state.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/org_switcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final prefsState = PreferencesState();
  final bootstrapFuture = _bootstrapApp(prefsState);

  runApp(
    BootstrapApp(
      bootstrapFuture: bootstrapFuture,
      prefsState: prefsState,
    ),
  );
}

Future<BootstrapResult> _bootstrapApp(PreferencesState prefsState) async {
  try {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint(
          'Note: .env file not found, using default/supabase credentials');
    }

    await Supabase.initialize(
      url: SupabaseService.supabaseUrl,
      anonKey: SupabaseService.supabaseAnonKey,
    );

    await prefsState.load();

    return BootstrapResult(
      isAuthenticated: Supabase.instance.client.auth.currentUser != null,
      initialRoute: Supabase.instance.client.auth.currentUser != null
          ? '/home'
          : '/login',
    );
  } catch (e) {
    debugPrint('Bootstrap error: $e');
    try {
      await prefsState.load();
    } catch (_) {
      // Keep defaults if preferences fail to load.
    }
    return const BootstrapResult(
      isAuthenticated: false,
      initialRoute: '/login',
    );
  }
}

class BootstrapResult {
  final bool isAuthenticated;
  final String initialRoute;

  const BootstrapResult({
    required this.isAuthenticated,
    required this.initialRoute,
  });
}

class BootstrapApp extends StatefulWidget {
  final Future<BootstrapResult> bootstrapFuture;
  final PreferencesState prefsState;

  const BootstrapApp({
    super.key,
    required this.bootstrapFuture,
    required this.prefsState,
  });

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  bool _ready = false;
  bool _minSplashElapsed = false;
  String _initialRoute = '/login';

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800)).then((_) {
      if (!mounted) return;
      setState(() {
        _minSplashElapsed = true;
      });
    });
    widget.bootstrapFuture.then((result) {
      if (!mounted) return;
      setState(() {
        _ready = true;
        _initialRoute = result.initialRoute;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider.value(value: widget.prefsState),
      ],
      child: MaterialApp(
        title: 'Mobifund',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        darkTheme: AppTheme.darkTheme,
        home: BootstrapGate(
          isReady: _ready && _minSplashElapsed,
          initialRoute: _initialRoute,
        ),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainShell(),
          '/platform': (context) => const PlatformShell(),
        },
      ),
    );
  }
}

class BootstrapGate extends StatefulWidget {
  final bool isReady;
  final String initialRoute;

  const BootstrapGate({
    super.key,
    required this.isReady,
    required this.initialRoute,
  });

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesState>();
    return Theme(
      data: prefs.themeMode == ThemeMode.dark
          ? AppTheme.darkTheme
          : AppTheme.theme,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 550),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: widget.isReady
            ? KeyedSubtree(
                key: ValueKey<String>(widget.initialRoute),
                child: _InitialRouteView(route: widget.initialRoute),
              )
            : const KeyedSubtree(
                key: ValueKey<String>('bootstrap-splash'),
                child: SplashScreen(autoNavigate: false),
              ),
      ),
    );
  }
}

class _InitialRouteView extends StatelessWidget {
  final String route;

  const _InitialRouteView({required this.route});

  @override
  Widget build(BuildContext context) {
    switch (route) {
      case '/welcome':
        return const WelcomeScreen();
      case '/register':
        return const RegisterScreen();
      case '/home':
        return const MainShell();
      case '/platform':
        return const PlatformShell();
      case '/login':
      default:
        return const LoginScreen();
    }
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Quick Actions',
                  style: AppTheme.headline.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = constraints.maxWidth < 420
                        ? (constraints.maxWidth - 12) / 2
                        : (constraints.maxWidth - 24) / 3;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.person_add_outlined,
                            'Add Member',
                            AppTheme.primary,
                            1,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.add_circle_outline,
                            'Contributions',
                            AppTheme.success,
                            2,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.remove_circle_outline,
                            'Expenses',
                            AppTheme.danger,
                            2,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.person_outline,
                            'Profile',
                            AppTheme.accent,
                            3,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.analytics_outlined,
                            'Reports',
                            AppTheme.primary,
                            0,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.settings_outlined,
                            'Settings',
                            AppTheme.info,
                            3,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
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
