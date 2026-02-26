import 'package:flutter/material.dart';

class CTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color buttonColor;

  const CTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.dark;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        overlayColor: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}
