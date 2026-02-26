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
  late final Animation<double> _animation;
  late final Animation<double> _fadeAnimation;

  // ✅ Prevent infinite “open settings” loop
  bool _openedLocationSettingsOnce = false;
  bool _openedAppSettingsOnce = false;

  Future<void> _performAsyncOperations() async {
    final SharedPreferences prefs = await _prefs;

    if (prefs.getString("api_secret") != null &&
        prefs.getString("api_key") != null) {
      isLoggedIn = true;
      final token = await getTocken();
      Logger().i(token);
    }

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<bool> _ensureLocationGateAndAutoOpenSettings() async {
    // 1) Location service ON?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ✅ Auto-open location settings (only once)
      if (!_openedLocationSettingsOnce) {
        _openedLocationSettingsOnce = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Geolocator.openLocationSettings();
        });
      }
      return false;
    }

    // 2) Permission
    var status = await Permission.locationWhenInUse.status;

    // If denied -> request (system popup)
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }

    // Permanently denied -> auto-open app settings (only once)
    if (status.isPermanentlyDenied ||
        status.isRestricted ||
        status.isLimited) {
      if (!_openedAppSettingsOnce) {
        _openedAppSettingsOnce = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await openAppSettings();
        });
      }
      return false;
    }

    return status.isGranted;
  }

  Future<void> _startFlow() async {
    if (!mounted) return;

    // ✅ gate first, auto-open settings if needed
    final ok = await _ensureLocationGateAndAutoOpenSettings();
    if (!ok) return;

    // ✅ then do your existing work and navigate
    await _performAsyncOperations();
    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.popAndPushNamed(context, Routes.homePage);
    } else {
      Navigator.popAndPushNamed(context, Routes.loginViewScreen);
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

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // ✅ Start after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlow());
  }

  // ✅ When user returns from Settings, continue flow
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            gradient: const LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/Logo D CMYK.png",
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      Text(
                        developedByPrefix,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        developedByCompany,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
