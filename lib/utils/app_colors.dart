import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  AppColors._();

  // Brand (from the RIVO logo)
  static const Color brand = Color(0xFF0A7CFF);
  static const Color brandSoft = Color(0x1A0A7CFF); // 10% tint for chips/badges

  // Light palette (iOS grouped style) – same names as before
  static const Color ink = Color(0xFF0A0A0B);
  static const Color paper = Color(0xFFF2F2F7); // grouped background
  static const Color surface = Colors.white;
  static const Color sand = Color(0xFFEFEFF4); // subtle fills
  static const Color line = Color(0xFFE0E0E6); // hairline separators
  static const Color muted = Color(0xFF6C6C70);
  static const Color subtle = Color(0xFF8E8E93);

  // iOS system semantic colors
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9F0A);

  // Dark palette (use via AppTheme.buildDark)
  static const Color inkDark = Colors.white;
  static const Color paperDark = Color(0xFF0A0A0B);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color sandDark = Color(0xFF2C2C2E);
  static const Color lineDark = Color(0xFF38383A);
}

class AppTheme {
  AppTheme._();

  static ThemeData build([Color primary = AppColors.brand]) => _make(
    primary: primary,
    dark: false,
    ink: AppColors.ink,
    paper: AppColors.paper,
    surface: AppColors.surface,
    line: AppColors.line,
    fill: AppColors.sand,
  );

  static ThemeData buildDark([Color primary = AppColors.brand]) => _make(
    primary: primary,
    dark: true,
    ink: AppColors.inkDark,
    paper: AppColors.paperDark,
    surface: AppColors.surfaceDark,
    line: AppColors.lineDark,
    fill: AppColors.sandDark,
  );

  static ThemeData _make({
    required Color primary,
    required bool dark,
    required Color ink,
    required Color paper,
    required Color surface,
    required Color line,
    required Color fill,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: surface,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(onPrimary: _onColor(primary));

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Plex',
      scaffoldBackgroundColor: paper,
      // iOS feel: no ripple, subtle highlight only
      splashFactory: NoSplash.splashFactory,
      highlightColor: fill,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );

    return base.copyWith(
      textTheme: Typography.tall2021
          .merge(base.textTheme)
          .apply(bodyColor: ink, displayColor: ink, fontSizeFactor: 1.sp),

      // Large, clean, flat app bar (iOS nav bar)
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Plex',
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),

      // Cards: flat, rounded, no shadow
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // Search-bar style inputs: filled, borderless until focused
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? surface : AppColors.sand,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: TextStyle(color: AppColors.subtle, fontSize: 15.sp),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(primary, 1.5),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.5),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: _onColor(primary),
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontFamily: 'Plex',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: primary.withOpacity(0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: TextStyle(
            fontFamily: 'Plex',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: TextStyle(
            fontFamily: 'Plex',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Chips: pill-shaped, tinted when selected
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: dark ? surface : AppColors.sand,
        selectedColor: primary,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontFamily: 'Plex',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Plex',
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),

      // Bottom tab bar (iOS-style)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withOpacity(dark ? 0.92 : 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? primary
                : AppColors.subtle,
            size: 26,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: 'Plex',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? primary
                : AppColors.subtle,
          ),
        ),
      ),

      // Bottom sheets & dialogs: big radius like iOS sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // iOS-green switch
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.success
              : (dark ? AppColors.sandDark : const Color(0xFFE5E5EA)),
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.sandDark : AppColors.ink,
        contentTextStyle: const TextStyle(
          fontFamily: 'Plex',
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dividerTheme: DividerThemeData(color: line, thickness: 0.5, space: 0.5),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static Color _onColor(Color c) =>
      c.computeLuminance() > 0.5 ? AppColors.ink : Colors.white;
}
