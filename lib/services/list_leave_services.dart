import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/leave_list.dart';

class ListLeaveServices {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    responseType: ResponseType.json,
  ));

  final Logger _log = Logger();

  Future<String> _getBaseUrl() async => await geturl();
  Future<String> _getToken() async => await getTocken();

  /// Common error handler
  void _handleError(DioException e, {String? message}) {
    String errorMsg = "An error occurred";
    try {
      if (e.response?.data is Map && e.response?.data["exception"] != null) {
        errorMsg =
            e.response!.data["exception"].toString().split(":").last.trim();
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
    } catch (_) {}

    _log.e("❌ Dio Error: $errorMsg | ${e.response}");
    Fluttertoast.showToast(
      msg: message ?? "Error: $errorMsg",
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<LeaveListDetails?> leaveListDetails() async {
    try {
      final url =
          '${await _getBaseUrl()}/api/method/mobile.mobile_env.app.get_leave_application_list';
      final token = await _getToken();

      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['data'] != null) {
          _log.i('Leave details fetched',
              error: response.data["data"]["employee"].toString());

          return LeaveListDetails.fromJson(response.data["data"]);
        }
      }
    } on DioException catch (e) {
      _handleError(e, message: "Failed to fetch lead dropdown details");
    } catch (e, st) {
      _log.e("Unexpected error fetching lead details: $e", stackTrace: st);
    }
    return null;
  }
}
