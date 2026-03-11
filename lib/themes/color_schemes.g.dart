import 'package:flutter/material.dart';

// ─── Brand colours (single source of truth) ──────────────────────────────────
const Color _kPrimary       = Color(0xFF1A56DB); // matches _T.primary
const Color _kPrimaryLight  = Color(0xFF3B76EF); // matches _T.primaryLight
const Color _kPrimaryDark   = Color(0xFF1240B0); // pressed / dark variant

// ─── Light theme ─────────────────────────────────────────────────────────────

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: _kPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _kPrimary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: Color(0xFFE2E8F0),
      disabledForegroundColor: Color(0xFF94A3B8),
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      textStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
  ),

  // FloatingActionButton
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _kPrimary,
    foregroundColor: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // Card
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: Color(0xFFE2E8F0)),
    ),
  ),

  // Input
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF0F4FA),
    labelStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
    hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: _kPrimary, width: 1.5),
    ),
  ),

  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: Color(0xFFEFF4FF),
    labelStyle: TextStyle(
        color: _kPrimary, fontWeight: FontWeight.w600, fontSize: 12),
    side: BorderSide.none,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: StadiumBorder(),
  ),

  // Divider
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE2E8F0),
    thickness: 1,
    space: 1,
  ),

  // Snackbar
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentTextStyle: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
  ),

  // Text
  textTheme: const TextTheme(
    titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.4),
    titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
        letterSpacing: -0.2),
    titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF334155)),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
    labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
        letterSpacing: 0.4),
  ),

  scaffoldBackgroundColor: const Color(0xFFF0F4FA),
);

// ─── Dark theme ──────────────────────────────────────────────────────────────

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1240B0),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _kPrimaryLight,
      foregroundColor: Colors.white,
      disabledBackgroundColor: Color(0xFF334155),
      disabledForegroundColor: Color(0xFF64748B),
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      textStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _kPrimaryLight,
    foregroundColor: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E2A3A),
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      side: const BorderSide(color: Color(0xFF2D3F55)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A2535),
    labelStyle:
    const TextStyle(color: Color(0xFF8DA4BE), fontSize: 13),
    hintStyle:
    const TextStyle(color: Color(0xFF4A6080), fontSize: 13),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: Color(0xFF2D3F55)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: Color(0xFF2D3F55)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: _kPrimaryLight, width: 1.5),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1A2D50),
    labelStyle: TextStyle(
        color: _kPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12),
    side: BorderSide.none,
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: const StadiumBorder(),
  ),

  dividerTheme: const DividerThemeData(
    color: Color(0xFF2D3F55),
    thickness: 1,
    space: 1,
  ),

  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.white),
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE2E8F0),
        letterSpacing: -0.4),
    titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E8F0),
        letterSpacing: -0.2),
    titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E8F0)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
    labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.4),
  ),

  scaffoldBackgroundColor: const Color(0xFF111827),
);

// ─── Light ColorScheme ────────────────────────────────────────────────────────

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _kPrimary,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFDBEAFF),
  onPrimaryContainer: Color(0xFF001E4D),
  secondary: Color(0xFF3B76EF),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFD6E4FF),
  onSecondaryContainer: Color(0xFF0A2A66),
  tertiary: Color(0xFF0891B2),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFFCCF0F8),
  onTertiaryContainer: Color(0xFF003544),
  error: Color(0xFFDC2626),
  errorContainer: Color(0xFFFFE4E4),
  onError: Colors.white,
  onErrorContainer: Color(0xFF7F1D1D),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF0F172A),
  surfaceContainerHighest: Color(0xFFE2E8F0),
  onSurfaceVariant: Color(0xFF64748B),
  outline: Color(0xFFCBD5E1),
  outlineVariant: Color(0xFFE2E8F0),
  onInverseSurface: Color(0xFFF8FAFC),
  inverseSurface: Color(0xFF1E293B),
  inversePrimary: Color(0xFF93C5FD),
  shadow: Color(0xFF000000),
  surfaceTint: _kPrimary,
  scrim: Color(0xFF000000),
);

// ─── Dark ColorScheme ─────────────────────────────────────────────────────────

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _kPrimaryLight,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF1240B0),
  onPrimaryContainer: Color(0xFFDBEAFF),
  secondary: Color(0xFF60A5FA),
  onSecondary: Color(0xFF002266),
  secondaryContainer: Color(0xFF1A3A6E),
  onSecondaryContainer: Color(0xFFBFD7FF),
  tertiary: Color(0xFF22D3EE),
  onTertiary: Color(0xFF003544),
  tertiaryContainer: Color(0xFF0E5A6E),
  onTertiaryContainer: Color(0xFFCCF0F8),
  error: Color(0xFFFCA5A5),
  errorContainer: Color(0xFF7F1D1D),
  onError: Color(0xFF450A0A),
  onErrorContainer: Color(0xFFFFE4E4),
  surface: Color(0xFF111827),
  onSurface: Color(0xFFE2E8F0),
  surfaceContainerHighest: Color(0xFF2D3F55),
  onSurfaceVariant: Color(0xFF94A3B8),
  outline: Color(0xFF334155),
  outlineVariant: Color(0xFF1E293B),
  onInverseSurface: Color(0xFF0F172A),
  inverseSurface: Color(0xFFE2E8F0),
  inversePrimary: _kPrimary,
  shadow: Color(0xFF000000),
  surfaceTint: _kPrimaryLight,
  scrim: Color(0xFF000000),
);