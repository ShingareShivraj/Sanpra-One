import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/holiday_model.dart';

class HolidayServices {
  HolidayServices({Dio? dio, Logger? logger})
      : _dio = dio ?? Dio(),
        _logger = logger ?? Logger();

  final Dio _dio;
  final Logger _logger;

  static const String _path =
      '/api/method/mobile.mobile_env.app.get_holiday_list';

  Future<List<HolidayList>> fetchHoliday(String year) async {
    try {
      final base = await geturl(); // don't store in global baseurl if possible
      final token = await getTocken();

      final res = await _dio.get(
        '$base$_path',
        queryParameters: {'year': year}, // ✅ correct for GET
        options: Options(
          headers: {'Authorization': token},
          responseType: ResponseType.json,
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (res.statusCode != 200) {
        _logger.w('Holiday API failed: ${res.statusCode} ${res.statusMessage}');
        return const [];
      }

      final data = res.data;

      // Expected: { "message": "...", "data": [ ... ] }
      final list = (data is Map<String, dynamic>) ? data['data'] : null;
      if (list is! List) return const [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => HolidayList.fromJson(e))
          .toList();
    } on DioException catch (e, st) {
      _logger.e(
        'fetchHoliday DioException: ${e.response?.statusCode} ${e.response?.data}',
        error: e,
        stackTrace: st,
      );
      return const [];
    } catch (e, st) {
      _logger.e('fetchHoliday error', error: e, stackTrace: st);
      return const [];
    }
  }
}
