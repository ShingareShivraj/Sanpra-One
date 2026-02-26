import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/add_visit_model.dart';
import 'package:logger/logger.dart';

import '../constants.dart';

class ListVisitServices {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  Future<List<AddVisitModel>> fetchVisit() async {
    try {
      final baseUrl = await geturl();
      final token = await getTocken();

      final response = await _dio.get(
        "$baseUrl/api/method/mobile.mobile_env.visit.get_visit_list",
        options: Options(
          headers: {"Authorization": token},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null || data["data"] == null) {
          return [];
        }

        final List list = data["data"];

        final visits = list.map((e) => AddVisitModel.fromJson(e)).toList();

        _logger.i("Visits fetched: ${visits.length}");
        return visits;
      }

      Fluttertoast.showToast(msg: "Unable to fetch visits");
      return [];
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final message =
          e.response?.data?["message"] ?? e.message ?? "Unknown error";

      _logger.e("Fetch Visit Error", error: message);

      if (statusCode == 401) {
        Fluttertoast.showToast(msg: "Session expired. Please login again.");
      } else if (statusCode == 500) {
        Fluttertoast.showToast(msg: "Server error. Try again later.");
      } else {
        Fluttertoast.showToast(msg: message);
      }

      return [];
    } catch (e, st) {
      _logger.e("Unexpected Error", error: e, stackTrace: st);
      Fluttertoast.showToast(msg: "Something went wrong");
      return [];
    }
  }
}
