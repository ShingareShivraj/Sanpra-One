import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/constants.dart';
import 'package:geolocation/services/login_services.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';

import '../../router.router.dart';

class LoginViewModel extends BaseViewModel {
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController urlController =
      TextEditingController(text: 'https://live.erpkey.in');
  final TextEditingController passwordController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool obscurePassword = true;
  bool isLoading = false;

  /// Initialize anything needed for the viewmodel
  void initialise() {
    // You can pre-load some data or do setup here if needed
  }

  /// Toggles password visibility and notifies UI
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  /// Validates the username input
  String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return "Enter a valid username";
    }
    return null;
  }

  /// Validates the password input
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Enter a Password";
    }
    return null;
  }

  /// Handles user login logic
  Future<void> loginWithUsernamePassword(BuildContext context) async {
    if (!formGlobalKey.currentState!.validate()) {
      return;
    }

    isLoading = true;
    notifyListeners();

    final baseUrl = urlController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Update global baseurl if needed
    baseurl = baseUrl;

    try {
      /// GET ANDROID ID
      const androidIdPlugin = AndroidId();
      String androidId = await androidIdPlugin.getId() ?? "unknown";


      /// LOGIN
      final bool loginSuccess =
      await LoginServices().login(baseUrl, username, password, androidId);

      if (loginSuccess) {
        if (context.mounted) {
          Navigator.popAndPushNamed(context, Routes.homePage);
        }
      } else {
        Logger().i('Invalid credentials');
        // Show feedback to user here, e.g. using a Snackbar or Toast
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Invalid Credentials")),
        // );
      }
    } catch (e, stacktrace) {
      Logger().e("Login error $stacktrace");
      // Show error to user if needed
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Dispose controllers and focus nodes when ViewModel is destroyed
  @override
  void dispose() {
    usernameController.dispose();
    urlController.dispose();
    passwordController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
