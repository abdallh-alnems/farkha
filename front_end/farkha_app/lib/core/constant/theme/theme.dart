import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

export 'colors.dart';
import 'colors.dart';

class AppTheme {
  ThemeData lightThemes() {
    final colorScheme = _lightColorScheme;
    return ThemeData(
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.appBackGroundColor,
      colorScheme: colorScheme,
      appBarTheme: _appBarTheme(
        backgroundColor: AppColors.appBackGroundColor,
        overlayBrightness: Brightness.dark,
        titleColor: colorScheme.primary,
      ),
      textTheme: _lightTextTheme,
      cardTheme: _lightCardTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutlineColor,
        thickness: 1,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme.primary),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      drawerTheme: const DrawerThemeData(surfaceTintColor: Colors.transparent),
    );
  }

  ThemeData darkThemes() {
    final colorScheme = _darkColorScheme;
    return ThemeData(
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.darkBackGroundColor,
      colorScheme: colorScheme,
      appBarTheme: _appBarTheme(
        backgroundColor: AppColors.darkBackGroundColor,
        overlayBrightness: Brightness.light,
        titleColor: colorScheme.primary,
      ),
      textTheme: _darkTextTheme,
      cardTheme: _darkCardTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutlineColor,
        thickness: 1,
      ),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme.primary),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ColorScheme get _lightColorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryColor,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondaryColor,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLight.withValues(alpha: 0.3),
    onSecondaryContainer: AppColors.secondaryColor,
    tertiary: AppColors.accentColor,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.accentLight.withValues(alpha: 0.2),
    onTertiaryContainer: AppColors.accentColor,
    error: AppColors.errorColor,
    onError: Colors.white,
    surface: AppColors.lightSurfaceColor,
    onSurface: const Color(0xFF2C2A25),
    surfaceContainerHighest: AppColors.appBackGroundColor,
    outline: AppColors.lightOutlineColor,
    outlineVariant: AppColors.lightOutlineColor.withValues(alpha: 0.5),
  );

  ColorScheme get _darkColorScheme => ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimaryColor,
    onPrimary: const Color(0xFF1A2E1A),
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.darkPrimaryColor,
    secondary: AppColors.secondaryLight,
    onSecondary: const Color(0xFF2A2510),
    secondaryContainer: AppColors.secondaryColor.withValues(alpha: 0.2),
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.accentLight,
    onTertiary: const Color(0xFF2A1A12),
    tertiaryContainer: AppColors.accentColor.withValues(alpha: 0.2),
    onTertiaryContainer: AppColors.accentLight,
    error: const Color(0xFFE57373),
    onError: const Color(0xFF1A0A0A),
    surface: AppColors.darkSurfaceColor,
    onSurface: const Color(0xFFE8E2D8),
    surfaceContainerHighest: AppColors.darkBackGroundColor,
    outline: AppColors.darkOutlineColor,
    outlineVariant: AppColors.darkOutlineColor.withValues(alpha: 0.5),
  );

  CardThemeData get _lightCardTheme => CardThemeData(
    color: AppColors.lightCardBackgroundColor,
    elevation: AppElevation.sm,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimens.borderMd,
      side: BorderSide(color: AppColors.lightOutlineColor.withValues(alpha: 0.5)),
    ),
    margin: EdgeInsets.zero,
  );

  CardThemeData get _darkCardTheme => CardThemeData(
    color: AppColors.darkSurfaceElevatedColor,
    elevation: AppElevation.none,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimens.borderMd,
      side: BorderSide(color: AppColors.darkOutlineColor.withValues(alpha: 0.5)),
    ),
    margin: EdgeInsets.zero,
  );

  AppBarTheme _appBarTheme({
    required Color backgroundColor,
    required Brightness overlayBrightness,
    required Color titleColor,
  }) => AppBarTheme(
    backgroundColor: backgroundColor,
    surfaceTintColor: backgroundColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: titleColor,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: overlayBrightness,
      statusBarBrightness:
          overlayBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: overlayBrightness,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: AppDimens.borderMd,
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimens.borderMd,
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimens.borderMd,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDimens.borderMd,
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDimens.borderMd,
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
      labelStyle: TextStyle(fontSize: 13.sp),
    );
  }

  TextTheme get _lightTextTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.primaryColor,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryColor,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryColor,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryColor,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2C2A25),
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2C2A25),
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2C2A25),
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF3A3730),
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF5A564C),
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF3A3730),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF4A4640),
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF6A665C),
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2C2A25),
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF5A564C),
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF7A766C),
      height: 1.4,
    ),
  );

  TextTheme get _darkTextTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.darkPrimaryColor,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.darkPrimaryColor,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.darkPrimaryColor,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.darkPrimaryColor,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFE8E2D8),
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFE8E2D8),
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontSize: 17.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFE8E2D8),
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFD0CAB8),
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFA09888),
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFD0CAB8),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFC0B8A8),
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF908878),
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFE8E2D8),
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFA09888),
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11.sp,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF807868),
      height: 1.4,
    ),
  );

  ElevatedButtonThemeData _elevatedButtonTheme(Color primary) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: AppElevation.sm,
          shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMd),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
        ),
      );
}

class AppDimens {
  AppDimens._();

  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 24.r;

  static BorderRadius get borderSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderXl => BorderRadius.circular(radiusXl);
}

class AppSpacing {
  AppSpacing._();

  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get md => 12.h;
  static double get lg => 16.h;
  static double get xl => 24.h;
  static double get xxl => 32.h;

  static double get screenH => 16.w;

  static EdgeInsets get padSm => EdgeInsets.all(sm);
  static EdgeInsets get padMd => EdgeInsets.all(md);
  static EdgeInsets get padLg => EdgeInsets.all(lg);
  static EdgeInsets get padXl => EdgeInsets.all(xl);

  static EdgeInsets hPad(double v) => EdgeInsets.symmetric(horizontal: v.w);
  static EdgeInsets vPad(double v) => EdgeInsets.symmetric(vertical: v.h);

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: screenH);
}

class AppElevation {
  AppElevation._();

  static double get none => 0;
  static double get sm => 1.0;
  static double get md => 2.0;
  static double get lg => 4.0;
  static double get xl => 8.0;

  static BoxShadow shadow({
    Color color = const Color(0xFF000000),
    double opacity = 0.08,
    double blurRadius = 8,
    Offset offset = const Offset(0, 2),
  }) => BoxShadow(
    color: color.withValues(alpha: opacity),
    blurRadius: blurRadius,
    offset: offset,
  );
}
