import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme.copyWith(
    primary: Colors.blueAccent, // BlueAccent for primary
    surfaceTint: Colors.blueAccent,
    inversePrimary: Colors.lightBlueAccent, // Lightened BlueAccent for inverse primary
  ),
  brightness: Brightness.light,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: darkColorScheme.copyWith(
    primary: Colors.blueAccent, // BlueAccent for primary
    surfaceTint: Colors.blueAccent,
    inversePrimary: Colors.lightBlueAccent, // Lightened BlueAccent for inverse primary
  ),
  brightness: Brightness.dark,
);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.blueAccent, // Primary color
  onPrimary: Colors.blueAccent, // Use blueAccent for text/icons on primary
  primaryContainer: Color(0xFFB3E0FF), // Soft blue container
  onPrimaryContainer: Color(0xFF003B73),
  secondary: Color(0xFF4C5D73),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFB3CCFF), // Lighter secondary
  onSecondaryContainer: Color(0xFF1B2A40),
  tertiary: Color(0xFF80A3FF), // Lighter tertiary
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFB3D1FF),
  onTertiaryContainer: Color(0xFF1C253B),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFF0F4FF), // Soft light surface
  onSurface: Color(0xFF1C1E21),
  surfaceContainerHighest: Color(0xFFD1D7DF),
  onSurfaceVariant: Color(0xFF3F4752),
  outline: Color(0xFF707D8C),
  onInverseSurface: Color(0xFFEFF1F4),
  inverseSurface: Color(0xFF2C3242),
  inversePrimary: Color(0xFF6694FF), // Lightened Navy Blue
  shadow: Color(0xFF000000),
  surfaceTint: Colors.blueAccent, // Use blueAccent for surface tint
  outlineVariant: Color(0xFFBFC9D1),
  scrim: Color(0xFF000000),
);


const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF6694FF), // Softer BlueAccent
  onPrimary: Color(0xFF002266),
  primaryContainer: Color(0xFF003366),
  onPrimaryContainer: Color(0xFFB3D1FF), // Even softer container blue
  secondary: Color(0xFF748A9E),
  onSecondary: Color(0xFF1E2F44),
  secondaryContainer: Color(0xFFB3CCFF), // Lighter secondary
  onSecondaryContainer: Color(0xFF98ABC5),
  tertiary: Color(0xFF6F7FAF),
  onTertiary: Color(0xFF1A253E),
  tertiaryContainer: Color(0xFF99B4FF),
  onTertiaryContainer: Color(0xFF99B4FF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF202533),
  onSurface: Color(0xFFE4E6EA),
  surfaceContainerHighest: Color(0xFF3F4752),
  onSurfaceVariant: Color(0xFFBFC9D1),
  outline: Color(0xFF8D98A3),
  onInverseSurface: Color(0xFF202533),
  inverseSurface: Color(0xFFE4E6EA),
  inversePrimary: Color(0xFF80C1FF), // Softer inverse primary
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF6694FF),
  outlineVariant: Color(0xFF3F4752),
  scrim: Color(0xFF000000),
);
