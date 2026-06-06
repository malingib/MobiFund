import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/enhanced_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/members_screen.dart';
import 'screens/modules_hub_screen.dart';
import 'screens/platform/platform_shell.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/report_center_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/app_state.dart';
import 'services/preferences_state.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/notifications_panel.dart';
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
  // Run env loading + supabase init + prefs load in parallel — they are
  // independent. Total wall-clock is now ~max(initA, initB, initC) instead
  // of initA + initB + initC.
  final results = await Future.wait<dynamic>([
    _loadEnv(),
    prefsState.load(),
  ], eagerError: false);

  try {
    await Supabase.initialize(
      url: SupabaseService.supabaseUrl,
      anonKey: SupabaseService.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  // Suppress unused-var warning from the eagerError result list.
  assert(results.length == 2);

  return BootstrapResult(
    isAuthenticated: Supabase.instance.client.auth.currentUser != null,
    initialRoute: Supabase.instance.client.auth.currentUser != null
        ? '/home'
        : '/login',
  );
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // .env missing is fine — credentials may come from --dart-define.
    // SupabaseService reads dart-define first, then dotenv, then defaults.
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
  // 4s hard cap on splash — only kicks in when something actually hangs.
  // No more artificial 1.8s floor for fast/no-network launches.
  bool _safetyTimeout = false;
  String _initialRoute = '/login';

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 4000)).then((_) {
      if (!mounted || _ready) return;
      setState(() {
        _safetyTimeout = true;
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
          isReady: _ready || _safetyTimeout,
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
    ReportCenterScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Members',
    'Modules',
    'Reports',
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
                            tabIndex: 1,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.add_circle_outline,
                            'Contributions',
                            AppTheme.success,
                            tabIndex: 2,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.remove_circle_outline,
                            'Expenses',
                            AppTheme.danger,
                            tabIndex: 2,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.person_outline,
                            'Profile',
                            AppTheme.accent,
                            onPush: (_) => const ProfileScreen(),
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.analytics_outlined,
                            'Reports',
                            AppTheme.primary,
                            tabIndex: 3,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _quickActionItem(
                            ctx,
                            Icons.settings_outlined,
                            'Settings',
                            AppTheme.info,
                            onPush: (_) => const SettingsScreen(),
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
    Color color, {
    int? tabIndex,
    WidgetBuilder? onPush,
  }) {
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        Navigator.pop(ctx);
        if (onPush != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: onPush),
          );
        } else if (tabIndex != null) {
          setState(() => _currentIndex = tabIndex);
        }
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
          Tooltip(
            message: state.isOnline ? 'Online' : 'Offline',
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: state.isOnline ? AppTheme.success : AppTheme.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
          NotificationsBadge(
            child: IconButton(
              icon: const Icon(Icons.notifications_none_outlined,
                  color: AppTheme.textPrimary),
              onPressed: () {
                AppHaptics.selection();
                showNotificationsSheet(context);
              },
              tooltip: 'Notifications',
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: _ProfileAvatarMenu(),
          ),
          const SizedBox(width: 4),
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

class _ProfileAvatarMenu extends StatelessWidget {
  const _ProfileAvatarMenu();

  String get _seed {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null || email.isEmpty) return 'mobifund';
    return email;
  }

  String get _avatarUrl =>
      'https://api.dicebear.com/9.x/avataaars/svg?seed=${Uri.encodeComponent(_seed)}';

  void _openProfile(BuildContext context) {
    AppHaptics.selection();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    AppHaptics.selection();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: AppTheme.bg,
            elevation: 0,
          ),
          body: const SettingsScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    AppHaptics.selection();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out of Mobifund?'),
        content: const Text(
          "You'll need to sign in again to access your group.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed != true) return;

    await SupabaseService().signOut();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Account',
      child: PopupMenuButton<_ProfileMenuAction>(
        tooltip: '',
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        color: AppTheme.surface,
        onSelected: (action) {
          switch (action) {
            case _ProfileMenuAction.profile:
              _openProfile(context);
              break;
            case _ProfileMenuAction.settings:
              _openSettings(context);
              break;
            case _ProfileMenuAction.logout:
              _confirmLogout(context);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.profile,
            child: Row(
              children: const [
                Icon(Icons.person_outline, color: AppTheme.textPrimary),
                SizedBox(width: 12),
                Text('Profile'),
              ],
            ),
          ),
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.settings,
            child: Row(
              children: const [
                Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
                SizedBox(width: 12),
                Text('Settings'),
              ],
            ),
          ),
          PopupMenuItem<_ProfileMenuAction>(
            value: _ProfileMenuAction.logout,
            child: Row(
              children: const [
                Icon(Icons.logout, color: AppTheme.danger),
                SizedBox(width: 12),
                Text(
                  'Log out',
                  style: TextStyle(color: AppTheme.danger),
                ),
              ],
            ),
          ),
        ],
        child: _ProfileAvatar(url: _avatarUrl),
      ),
    );
  }
}

enum _ProfileMenuAction { profile, settings, logout }

class _ProfileAvatar extends StatelessWidget {
  final String url;

  const _ProfileAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: ClipOval(
        child: SvgPicture.network(
          url,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => const _AvatarPlaceholder(),
          errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_outline,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
