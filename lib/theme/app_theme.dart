import 'package:flutter/material.dart';

class AppTheme {
  // Global theme mode controller
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  static void toggleMode() {
    final current = mode.value;
    if (current == ThemeMode.light) {
      mode.value = ThemeMode.dark;
    } else {
      mode.value = ThemeMode.light;
    }
  }

  // Cane color palette (provided)
  static const Map<int, Color> _caneMap = {
    50: Color(0xFFF7FEE7),
    100: Color(0xFFECFCCA),
    200: Color(0xFFD8F999),
    300: Color(0xFFBBF451),
    400: Color(0xFF9AE600),
    500: Color(0xFF7CCF00), // primary
    600: Color(0xFF5EA500),
    700: Color(0xFF497D00),
    800: Color(0xFF3C6300),
    900: Color(0xFF35530E),
    950: Color(0xFF192E03),
  };

  static const MaterialColor cane = MaterialColor(0xFF7CCF00, _caneMap);

  // Convenience accessors
  static final Color cane50 = _caneMap[50]!;
  static final Color cane100 = _caneMap[100]!;
  static final Color cane200 = _caneMap[200]!;
  static final Color cane300 = _caneMap[300]!;
  static final Color cane400 = _caneMap[400]!;
  static final Color cane500 = _caneMap[500]!;
  static final Color cane600 = _caneMap[600]!;
  static final Color cane700 = _caneMap[700]!;
  static final Color cane800 = _caneMap[800]!;
  static final Color cane900 = _caneMap[900]!;
  static final Color cane950 = _caneMap[950]!;

  static ThemeData light() {
    final cs = ColorScheme.fromSwatch(
      primarySwatch: cane,
    ).copyWith(secondary: cane700, surface: const Color(0xFFF3FFF7));

    return ThemeData(
      primarySwatch: cane,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: cane500,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: cane500),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    final cs = base.colorScheme.copyWith(
      primary: cane500,
      secondary: cane300,
      surface: const Color(0xFF0F1A10),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF111B12),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7CCF00),
        foregroundColor: Colors.black,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return cane500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return cane700.withAlpha((0.6 * 255).round());
        }),
      ),
    );
  }
}
