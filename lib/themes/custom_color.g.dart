import 'package:flutter/material.dart';

const blueAccent = Color(0xFF448AFF); // Define the primary BlueAccent color

CustomColors lightCustomColors = const CustomColors(
  sourceCustomcolor1: blueAccent,
  customcolor1: Color(0xFF0065C2), // A shade for light theme
  onCustomcolor1: Color(0xFFFFFFFF), // Text color on customcolor1
  customcolor1Container: Color(0xFFE3F2FD), // Light background for containers
  onCustomcolor1Container: Color(0xFF00376B), // Text color on container background
);

CustomColors darkCustomColors = const CustomColors(
  sourceCustomcolor1: blueAccent,
  customcolor1: Color(0xFF90CAF9), // A lighter shade for dark theme
  onCustomcolor1: Color(0xFF002D5B), // Text color on customcolor1
  customcolor1Container: Color(0xFF1E88E5), // Darker background for containers
  onCustomcolor1Container: Color(0xFFE3F2FD), // Text color on container background
);

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceCustomcolor1,
    required this.customcolor1,
    required this.onCustomcolor1,
    required this.customcolor1Container,
    required this.onCustomcolor1Container,
  });

  final Color? sourceCustomcolor1;
  final Color? customcolor1;
  final Color? onCustomcolor1;
  final Color? customcolor1Container;
  final Color? onCustomcolor1Container;

  @override
  CustomColors copyWith({
    Color? sourceCustomcolor1,
    Color? customcolor1,
    Color? onCustomcolor1,
    Color? customcolor1Container,
    Color? onCustomcolor1Container,
  }) {
    return CustomColors(
      sourceCustomcolor1: sourceCustomcolor1 ?? this.sourceCustomcolor1,
      customcolor1: customcolor1 ?? this.customcolor1,
      onCustomcolor1: onCustomcolor1 ?? this.onCustomcolor1,
      customcolor1Container: customcolor1Container ?? this.customcolor1Container,
      onCustomcolor1Container: onCustomcolor1Container ?? this.onCustomcolor1Container,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceCustomcolor1: Color.lerp(sourceCustomcolor1, other.sourceCustomcolor1, t),
      customcolor1: Color.lerp(customcolor1, other.customcolor1, t),
      onCustomcolor1: Color.lerp(onCustomcolor1, other.onCustomcolor1, t),
      customcolor1Container: Color.lerp(customcolor1Container, other.customcolor1Container, t),
      onCustomcolor1Container: Color.lerp(onCustomcolor1Container, other.onCustomcolor1Container, t),
    );
  }

  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith();
  }
}
