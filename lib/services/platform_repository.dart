import 'package:flutter/services.dart';

class PlatformRepository {
  static const platform =  MethodChannel('soham/color');

  Future<String> changeColor(String color) async {
    try {
      final String result = await platform.invokeMethod("changeColor", {
        "color": color,
      });
      print('RESULT -> $result');
      color = result;
    } on PlatformException catch (e) {
      print(e);
    }
    return color;
  }
}