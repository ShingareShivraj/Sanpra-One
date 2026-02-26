import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/comp_off_model.dart';

class CompOffServices {
  final Dio _dio;
  final Logger _logger = Logger();

  CompOffServices()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  Future<bool> delete(String? id) async {
    baseurl = await geturl();
    try {
      final response = await _dio.delete(
        '$baseurl/api/method/mobile.mobile_env.app.delete_compoff_application',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
        queryParameters: {
          "name": id,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e, s) {
      _logDioError(e, s);
      return false;
    } catch (e, s) {
      _logger.e('Unexpected error in getLeaveTypes', error: e, stackTrace: s);
      return false;
    }
  }

  // -------------------- GET LEAVE TYPES --------------------
  Future<List<String>> getLeaveTypes() async {
    final baseUrl = await geturl();

    try {
      final response = await _dio.get(
        '$baseUrl/api/method/mobile.mobile_env.app.get_compoffleave_type',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final List list = response.data['data'] ?? [];
      return list.map((e) => e['name'].toString()).toList();
    } on DioException catch (e, s) {
      _logDioError(e, s);
      return [];
    } catch (e, s) {
      _logger.e('Unexpected error in getLeaveTypes', error: e, stackTrace: s);
      return [];
    }
  }

  // -------------------- ADD LEAVE --------------------
  Future<bool> addLeave(CompOff leaveData) async {
    final baseUrl = await geturl();

    try {
      final response = await _dio.post(
        '$baseUrl/api/method/mobile.mobile_env.app.make_compoff_application',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
        data: leaveData.toJson(), // 🔥 no manual json.encode
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e, s) {
      _logDioError(e, s);
      return false;
    } catch (e, s) {
      _logger.e('Unexpected error in addLeave', error: e, stackTrace: s);
      return false;
    }
  }

  Future<List<CompOff>> getAttendanceRequests(int month, int year) async {
    baseurl = await geturl();
    var data = {'year': '$year', 'month': '$month'};
    try {
      var dio = Dio();
      var response = await dio.request(
          '$baseurl/api/method/mobile.mobile_env.app.get_compoff_request_list',
          options: Options(
            method: 'GET',
            headers: {'Authorization': await getTocken()},
          ),
          data: data);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<CompOff> caneList = List.from(jsonData["data"])
            .map<CompOff>((data) => CompOff.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch request");
        return [];
      }
    } on DioException catch (e, s) {
      _logDioError(e, s);
      return [];
    } catch (e, s) {
      _logger.e('Unexpected error in update Leave', error: e, stackTrace: s);
      return [];
    }
  }

  Future<bool> updateLeave(CompOff leaveData) async {
    final baseUrl = await geturl();

    try {
      final response = await _dio.post(
        '$baseUrl/api/method/mobile.mobile_env.app.update_compoff_application',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
        data: leaveData.toJson(), // 🔥 no manual json.encode
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e, s) {
      _logDioError(e, s);
      return false;
    } catch (e, s) {
      _logger.e('Unexpected error in update Leave', error: e, stackTrace: s);
      return false;
    }
  }

  Future<CompOff?> getLeave(String id) async {
    try {
      final baseUrl = await geturl();

      final res = await _dio.get(
        '$baseUrl/api/method/mobile.mobile_env.app.get_compoff_application',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
        queryParameters: {
          "name": id,
        },
      );
      if (res.statusCode == 200) {
        return CompOff.fromJson(res.data["data"]);
      } else {
        return null;
      }
    } on DioException catch (e, s) {
      _logDioError(e, s);
      return null;
    } catch (e, s) {
      _logger.e('Unexpected error in addLeave', error: e, stackTrace: s);
      return null;
    }
  }

  // -------------------- ERROR HANDLING --------------------
  void _logDioError(DioException e, StackTrace s) {
    String message;

    // 1️⃣ Extract readable message
    if (e.response?.data is Map) {
      message = e.response?.data['message'] ??
          e.response?.data['exception'] ??
          'Server error occurred';
    } else {
      message = e.message ?? 'Network error occurred';
    }

    // 2️⃣ Clean server exception text (optional but recommended)
    message = message.toString().replaceAll('Exception:', '').trim();

    // 3️⃣ Show toast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFFBA1A1A),
      textColor: const Color(0xFFFFFFFF),
    );

    // 4️⃣ Log full technical error
    _logger.e(
      'Dio Error: $message',
      error: e,
      stackTrace: s,
    );
  }
}
