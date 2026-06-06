import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────
// SPACING SCALE
// 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 — no other values.
// ─────────────────────────────────────────
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double xxxxl = 64;

  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const EdgeInsets pagePaddingTight = EdgeInsets.all(16);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets pageBottom = EdgeInsets.fromLTRB(20, 16, 20, 24);

  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gap2xl = SizedBox(height: xxl, width: xxl);
  static const SizedBox gap3xl = SizedBox(height: xxxl, width: xxxl);
}

// ─────────────────────────────────────────
// MOTION TOKENS
// Subtle, premium. Micro/Fast for hovers, Base for page transitions,
// Slow for hero animations.
// ─────────────────────────────────────────
class AppDuration {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
}

class AppCurves {
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOutQuart;
  static const Curve accelerate = Curves.easeInQuart;
}

// ─────────────────────────────────────────
// ICON SIZE SCALE
// ─────────────────────────────────────────
class AppIconSize {
  static const double xs = 14;
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 28;
  static const double xl = 36;
  static const double xxl = 48;
}

class AppTheme {
  // Grounded finance palette inspired by ZenLipa's calm, trust-first feel.
  static const Color primary = Color(0xFF0D7168); // Deep teal
  static const Color primaryDark = Color(0xFF094943);
  static const Color primaryLight = Color(0xFF38B2A3);
  static const Color accent = Color(0xFFD9AE4A); // Warm gold
  static const Color accent2 = Color(0xFF8AD7AE); // Soft mint
  static const Color brandInk = Color(0xFF102A26);

  // Light theme
  static const Color bg = Color(0xFFF4F7F3);
  static const Color surface = Color(0xFFEAF2EC);
  static const Color surface2 = Color(0xFFFCFDFB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFD9E4DD);

  // Dark theme (for cards/sections)
  static const Color darkCard = Color(0xFF12302B);

  // Decorative tints — used on dark surfaces (hero cards, splash, etc.)
  // where we need a hint of white that still reads as a *tint*, not a fill.
  // 12% alpha is the calibrated "barely there" value; keep the family
  // together so any future opacity rebalance happens in one place.
  static const Color heroDecorationWhite = Color(0x14FFFFFF);
  static const Color heroDecorationPrimarySoft = Color(0x140D7168);
  static const Color heroDecorationAccentSoft = Color(0x14D9AE4A);

  // Shared layout tokens
  static const double radiusSm = 14;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 28;
  // Pills (status chips, badges, hero chip replacements). Always 999
  // when the visual goal is "fully rounded."
  static const double radiusPill = 999;
  static const double pagePadding = 20;

  // Text colors
  static const Color textPrimary = Color(0xFF17312D);
  static const Color textSecondary = Color(0xFF5A6964);
  static const Color textLight = Color(0xFF8A9792);
  // Alias for backward compatibility

  // Status colors
  static const Color success = Color(0xFF169A6A);
  static const Color danger = Color(0xFFE25555);
  static const Color warning = Color(0xFFE3A61B);
  static const Color info = Color(0xFF2F80ED);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D7168), Color(0xFF124F49), Color(0xFF0E2E2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFF8FBF7), Color(0xFFE9F3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5B84A), Color(0xFFD39A19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF183833), Color(0xFF102A26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────
  // SHADOW TOKENS
  // Named so any future rebalance is one place.
  // Hero glow: deeper drop in the brand's own hue (the only colored
  // shadow in the system). Card ambient: a barely-there lift.
  // ─────────────────────────────────────────
  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0F0D7168), // primary @ ~6%
      blurRadius: 18,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> shadowHero = [
    BoxShadow(
      color: Color(0x290D7168), // primary @ ~16%
      blurRadius: 28,
      offset: Offset(0, 14),
    ),
  ];

  // ─────────────────────────────────────────
  // CARD CHROME
  // ─────────────────────────────────────────
  // 1px Edge border at ~78% alpha — the structural border on elevated
  // cards. Avoids the SaaS-card-without-border or card-with-grey-border
  // failure modes.
  static const BorderSide cardBorder =
      BorderSide(color: Color(0xC7D9E4DD), width: 1);

  // The 48dp white-tint icon tile used inside the dashboard hero and the
  // settings hero. 12% white over the hero gradient reads as "icon chip
  // set into the brand surface" without competing with the headline.
  static const BoxDecoration heroIconTile = BoxDecoration(
    color: Color(0x1FFFFFFF), // 12% white
    borderRadius: BorderRadius.all(Radius.circular(radiusSm + 2)),
    border: Border.fromBorderSide(
      BorderSide(color: Color(0x1FFFFFFF)),
    ),
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        visualDensity: VisualDensity.standard,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: danger,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ).apply(bodyColor: textPrimary, displayColor: textPrimary),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bg,
          selectedItemColor: primary,
          unselectedItemColor: textLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: surface2,
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.06),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
            side: BorderSide(color: border.withValues(alpha: 0.82)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface2,
          labelStyle: const TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(color: textLight, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
        iconTheme: const IconThemeData(color: textSecondary, size: 20),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
          space: 1,
        ),
        dividerColor: border,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: textPrimary,
          contentTextStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: _AppPageTransitionsBuilder(),
            TargetPlatform.iOS: _AppPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: primaryLight,
          secondary: accent,
          surface: Color(0xFF1C2725),
          error: danger,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.15,
          ),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C2725),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1C2725),
          elevation: 0,
          shadowColor: Colors.black54,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1C2725),
          selectedItemColor: primaryLight,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C2725),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primaryLight, width: 1.4),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        dividerColor: const Color(0xFF3A3A3A),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF3A3A3A),
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2C2C2C),
          contentTextStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: _AppPageTransitionsBuilder(),
            TargetPlatform.iOS: _AppPageTransitionsBuilder(),
          },
        ),
      );

  // Text styles
  static TextStyle get displayLarge => const TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      );

  static TextStyle get monoFont => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get displayMedium => const TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
      );

  static TextStyle get headline => const TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => const TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get caption => const TextStyle(
        color: textLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  // Compact labels for chips, list-row metadata, and "X contributions".
  // 12px meets the Material 12sp floor; 600 weight so it reads as a label,
  // not body copy.
  static TextStyle get label => const TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // The dominant weight in lists: a member name, an expense description,
  // an activity label. 14px, 600 weight, primary color for emphasis.
  static TextStyle get rowTitle => const TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  // The number inside a quick-stat tile or recent-activity amount.
  // 16-18px, 800 weight, primary color. Larger than rowTitle because the
  // number is the focal point of a stat row.
  static TextStyle get tileValue => const TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      );

  // A section header. 20-22px, 800 weight. Used in the dashboard's
  // "Analytics" section header and on landing surfaces.
  static TextStyle get sectionHeader => const TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      );

  // The hero balance number on the dashboard. 33px, 800 weight, with
  // tight letter-spacing for a confident ledger number. One per screen.
  static TextStyle get heroBalance => const TextStyle(
        color: textPrimary,
        fontSize: 33,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get button => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );
}

class AppHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.vibrate();
}

// ─────────────────────────────────────────
// PAGE TRANSITIONS
// A single calm motion: fade + 12px slide-from-trailing-edge.
// Applied to both Android and iOS via pageTransitionsTheme.
// ─────────────────────────────────────────
class _AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Respect the OS-level "reduce motion" preference. When the user has
    // opted out, render the destination instantly with no fade or slide.
    if (MediaQuery.of(context).disableAnimations) {
      return child;
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: AppCurves.standard,
      reverseCurve: AppCurves.emphasized,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
