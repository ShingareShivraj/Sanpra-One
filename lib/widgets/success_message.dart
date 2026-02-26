import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SuccessNotification {
  static void show({required String message}) {
    var navigatorKey;
    showTopSnackBar(
      Overlay.of(navigatorKey.currentContext),
      CustomSnackBar.success(
        message: message, // Default message if not provided
      ),
    );
  }
}
