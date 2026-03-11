import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginServices {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> login(String url, String username, String password, String androidId) async {
    print("ANDROID ID SENT TO SERVER: $androidId");


    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var data = {
      'usr': username,
      'pwd': password,
      'android_id': androidId
    };
    var dio = Dio();

    try {
      var response = await dio.request(
        '$url/api/method/mobile.mobile_env.app.login',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await _prefs;
        Logger().i(response.data.toString());

        prefs.setString("url", url);
        prefs.setString("api_secret",
            response.data["key_details"]["api_secret"].toString());
        prefs.setString(
            "api_key", response.data["key_details"]["api_key"].toString());
        prefs.setString("user", response.data["user"].toString());

        Logger().i(prefs.getString('api_secret'));

        Fluttertoast.showToast(
          gravity: ToastGravity.BOTTOM,
          msg: 'Logged in successfully',
          textColor: Color(0xFFFFFFFF),
          backgroundColor: Color.fromARGB(255, 26, 186, 82),
        );
        return true;
      } else {
        Fluttertoast.showToast(
          gravity: ToastGravity.BOTTOM,
          msg: 'Login failed. Please try again.',
          textColor: Color(0xFFFFFFFF),
          backgroundColor: Color(0xFFBA1A1A),
        );
        return false;
      }
    } on DioException catch (e) {
      String errorMsg = 'Unknown error occurred.';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMsg = 'Connection timed out. Please check your network.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Response timed out. Try again later.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMsg = e.response?.data["message"]?.toString() ??
            'Invalid response from server.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMsg = 'No Internet connection or unexpected error.';
      }

      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: 'Error: $errorMsg',
        textColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFFBA1A1A),
      );
      Logger().e('DioException: ${e.response?.data}');
      return false;
    } catch (e, stacktrace) {
      Logger().e('Unhandled exception: $e\n$stacktrace');
      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: 'Unexpected error occurred. Please contact support.',
        textColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFFBA1A1A),
      );
      return false;
    }
  }
}
