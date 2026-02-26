import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/tour_model.dart';

class TourServices {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  Future<List<Tour>> fetchTours() async {
    baseurl = await geturl();

    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/resource/Tours?fields=["area","total_calls","date","name","description"]',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<Tour> caneList = List.from(jsonData["data"])
            .map<Tour>((data) => Tour.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch items");
        return [];
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.response?.data['message'].toString()}",
        backgroundColor: Color(0xFFBA1A1A),
        textColor: Color(0xFFFFFFFF),
      );
      Logger().e(e.response?.data['message'].toString());
      return [];
    }
  }

  Future<bool> addTour(Tour orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/method/mobile.mobile_env.app.create_tour',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: response.data['message'].toString());
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<bool> deleteTour(String? id) async {
    if (id == null || id.isEmpty) return false;

    baseurl = await geturl();

    try {
      final response = await _dio.delete(
        '$baseurl/api/resource/Tours/$id',
        options: Options(
          headers: {'Authorization': await getTocken()},
          validateStatus: (status) {
            // ✅ Accept 200–299 as success
            return status != null && status >= 200 && status < 300;
          },
        ),
      );

      // ✅ If we reached here, delete succeeded
      return true;
    } catch (e) {
      _handleError(e, "Failed to delete Tour");
      return false;
    }
  }

  void _handleError(dynamic error, String fallbackMessage) {
    if (error is DioException) {
      final message = error.response?.data["exception"] ??
          error.response?.data["message"] ??
          fallbackMessage;

      Fluttertoast.showToast(
        msg: "Error: ${message.toString()}",
        backgroundColor: const Color(0xFFBA1A1A),
        textColor: const Color(0xFFFFFFFF),
        gravity: ToastGravity.BOTTOM,
      );

      _logger.e("DioException: ${error.response}");
    } else {
      Fluttertoast.showToast(
        msg: fallbackMessage,
        backgroundColor: const Color(0xFFBA1A1A),
        textColor: const Color(0xFFFFFFFF),
      );
      _logger.e(error);
    }
  }
}
