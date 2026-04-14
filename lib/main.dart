import 'package:firebase_core/firebase_core.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocation/router.locator.dart';
import 'package:geolocation/screens/splash_screen/splash_screen.dart';
import 'package:geolocation/themes/color_schemes.g.dart';
import 'package:geolocation/themes/custom_color.g.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

import 'router.router.dart';
import 'services/notification_service.dart'; // 🔥 ADD THIS

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  // 🔥 ONLY THIS LINE handles all notifications
  await NotificationService().init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background message: ${message.data}");
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
