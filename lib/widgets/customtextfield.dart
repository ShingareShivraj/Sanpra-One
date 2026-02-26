import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSmallTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardtype;
  final int? length;
  final bool readOnly;
  final int lineLength;
  final AutovalidateMode autovalidateMode;

  const CustomSmallTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.keyboardtype,
    this.length,
    this.readOnly = false,
    this.lineLength = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: lineLength,
        keyboardType: keyboardtype,
        onChanged: onChanged,
        validator: validator,
        autovalidateMode: autovalidateMode,
        inputFormatters:
            length != null ? [LengthLimitingTextInputFormatter(length)] : null,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: readOnly
              ? colorScheme.surfaceVariant.withOpacity(0.4)
              : colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          suffixIcon: suffixIcon,
          labelStyle: theme.textTheme.labelMedium,
          hintStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          border: _outlineBorder(colorScheme.outline),
          enabledBorder: _outlineBorder(colorScheme.outlineVariant),
          focusedBorder: _outlineBorder(colorScheme.primary, width: 1.8),
          errorBorder: _outlineBorder(colorScheme.error),
          focusedErrorBorder: _outlineBorder(colorScheme.error, width: 1.8),
          disabledBorder: _outlineBorder(colorScheme.outlineVariant),
        ),
      ),
    );
  }

  static OutlineInputBorder _outlineBorder(
    Color color, {
    double width = 1.4,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
