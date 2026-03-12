import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../router.router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static const String developedByCompany = "Sanpra Software Solutions";
  static const String developedByPrefix = "Developed by";

  bool isLoggedIn = false;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  bool _openedLocationSettingsOnce = false;
  bool _openedAppSettingsOnce = false;

  Future<void> _performAsyncOperations() async {
    final prefs = await _prefs;

    if (prefs.getString("api_secret") != null &&
        prefs.getString("api_key") != null) {
      isLoggedIn = true;
      final token = await getTocken();
      Logger().i(token);
    }

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<bool> _ensureLocationGateAndAutoOpenSettings() async {

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!_openedLocationSettingsOnce) {
        _openedLocationSettingsOnce = true;
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isPermanentlyDenied ||
        status.isRestricted ||
        status.isLimited) {

      if (!_openedAppSettingsOnce) {
        _openedAppSettingsOnce = true;
        await openAppSettings();
      }
      return false;
    }

    return status.isGranted;
  }

  Future<void> _startFlow() async {

    if (!mounted) return;

    final ok = await _ensureLocationGateAndAutoOpenSettings();

    if (!ok) return;

    await _performAsyncOperations();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.homePage);
    } else {
      Navigator.pushReplacementNamed(context, Routes.loginViewScreen);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlow());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startFlow();
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// LOGO
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        "assets/images/Logo D CMYK.png",
                        scale: 1,
                      ),
                    ),
                    const SizedBox(height: 30),
                    /// LOADER
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// FOOTER
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [

                    Text(
                      developedByPrefix,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      developedByCompany,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
}