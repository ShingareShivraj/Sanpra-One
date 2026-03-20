import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocation/router.locator.dart';
import 'package:geolocation/screens/splash_screen/splash_screen.dart';
import 'package:geolocation/themes/color_schemes.g.dart';
import 'package:geolocation/themes/custom_color.g.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'router.router.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  await NotificationService().init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          lightScheme = lightColorScheme.copyWith(primary: Colors.blueAccent);
          darkScheme = darkColorScheme.copyWith(primary: Colors.blueAccent);
        }

        lightScheme = lightScheme.copyWith(
          primary: Colors.blueAccent,
          onPrimary: Colors.white,
        );

        darkScheme = darkScheme.copyWith(
          primary: Colors.blueAccent,
          onPrimary: Colors.white,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: StackedService.navigatorKey,
          onGenerateRoute: StackedRouter().onGenerateRoute,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            colorScheme: lightScheme,
            appBarTheme: AppBarTheme(
              backgroundColor: lightScheme.primary,
              foregroundColor: lightScheme.onPrimary,
            ),
            extensions: [lightCustomColors],
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            colorScheme: darkScheme,
            extensions: [darkCustomColors],
          ),
          themeMode: ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
