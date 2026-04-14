import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool trackingEnabled = false;

  void setTracking(bool value) {
    trackingEnabled = value;
  }
}