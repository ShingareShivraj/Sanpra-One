import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/attendance_model.dart';

class AttendanceServices {
  final Logger _logger = Logger();

  // ─────────────────────────────────────────────────────────────
  // Reusable Dio instance (IMPORTANT for performance)
  // ─────────────────────────────────────────────────────────────
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ),
  );

  // ─────────────────────────────────────────────────────────────
  // Fetch Attendance List
  // ─────────────────────────────────────────────────────────────
  Future<List<AttendanceList>> fetchAttendance(
    int year,
    int month,
  ) async {
    try {
      final baseUrl = await geturl();
      final token = await getTocken();

      final response = await _dio.get(
        '$baseUrl/api/method/mobile.mobile_env.app.get_attendance_list',
        options: Options(
          headers: {'Authorization': token},
        ),
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      final data = response.data?['data'];
      if (data == null || data['attendance_list'] == null) {
        return [];
      }

      return (data['attendance_list'] as List)
          .map((e) => AttendanceList.fromJson(e))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    } catch (e) {
      _logger.e('Unknown error in fetchAttendance', error: e);
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Fetch Attendance Summary / Details
  // ─────────────────────────────────────────────────────────────
  Future<AttendanceDetails> fetchAttendanceDetails(
    int year,
    int month,
  ) async {
    try {
      final baseUrl = await geturl();
      final token = await getTocken();

      final response = await _dio.get(
        '$baseUrl/api/method/mobile.mobile_env.app.get_attendance_list',
        options: Options(
          headers: {'Authorization': token},
        ),
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      final details = response.data?['data']?['attendance_details'];
      if (details == null) {
        return AttendanceDetails();
      }

      return AttendanceDetails.fromJson(details);
    } on DioException catch (e) {
      _handleDioError(e);
      return AttendanceDetails();
    } catch (e) {
      _logger.e('Unknown error in fetchAttendanceDetails', error: e);
      return AttendanceDetails();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Centralized Error Handling
  // ─────────────────────────────────────────────────────────────
  void _handleDioError(DioException e) {
    final message =
        e.response?.data?['message']?.toString() ?? 'Something went wrong';

    _logger.e(message, error: e);
  }
}
