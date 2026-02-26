import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/expense_model.dart';

class AddExpenseServices {
  final Logger _log = Logger();

  /// Create Dio instance with auth header
  Future<Dio> _dio() async {
    final dio = Dio();
    dio.options.headers = {
      'Authorization': await getTocken(),
    };
    return dio;
  }

  /// -------------------------------
  /// CREATE EXPENSE
  /// -------------------------------
  Future<bool> bookexpense(ExpenseData expense) async {
    baseurl = await geturl();

    try {
      final dio = await _dio();

      final response = await dio.post(
        '$baseurl/api/method/mobile.mobile_env.app.book_expense',
        data: expense.toJson(),
      );

      if (response.statusCode == 200) {
        _showToast(
          response.data["message"]?.toString() ?? "Expense Created",
          success: true,
        );
        return true;
      }

      _showToast("Unable to create expense");
      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseData expense) async {
    baseurl = await geturl();

    try {
      final dio = await _dio();

      final response = await dio.post(
        '$baseurl/api/method/mobile.mobile_env.app.book_expense',
        data: expense.toJson(),
      );

      if (response.statusCode == 200) {
        _showToast(
          response.data["message"]?.toString() ?? "Expense Created",
          success: true,
        );
        return true;
      }

      _showToast("Unable to create expense");
      return false;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  /// -------------------------------
  /// FETCH EXPENSE TYPES
  /// -------------------------------
  Future<List<String>> fetExpenseType() async {
    baseurl = await geturl();

    try {
      final dio = await _dio();

      final response = await dio.get(
        '$baseurl/api/resource/Expense Claim Type',
        queryParameters: {'limit_page_length': 999},
      );

      if (response.statusCode == 200) {
        final List data = response.data["data"] ?? [];
        return data.map((e) => e["name"].toString()).toList();
      }

      _showToast("Unable to load expense types");
      return [];
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    }
  }

  Future<bool> delete(String? id) async {
    baseurl = await geturl();
    final dio = await _dio();

    try {
      final response = await dio.delete(
        '$baseurl/api/method/mobile.mobile_env.app.delete_expense_application',
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
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTravelExpenseData({
    required String vehicleType,
    required String date, // yyyy-MM-dd
  }) async {
    final baseUrl = await geturl();
    final dio = await _dio();

    try {
      final response = await dio.get(
        '$baseUrl/api/method/mobile.mobile_env.app.get_travel_expense_data',
        queryParameters: {
          'expense_type': vehicleType, // <-- match backend param name
          'expense_date': date, // <-- match backend param name
        },
        options: Options(
          headers: {'Authorization': await getTocken()},
          validateStatus: (_) =>
              true, // <-- prevents Dio from throwing on non-200
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data["data"];
        if (data != null) {
          final double ratePerKm =
              double.tryParse(data["rate_per_km"].toString()) ?? 0.0;
          final double km = double.tryParse(data["km"].toString()) ?? 0.0;
          final double amount = ratePerKm * km;

          return {
            "ratePerKm": ratePerKm,
            "km": km,
            "amount": amount,
          };
        } else {
          print("No travel data returned: ${response.data}");
          Fluttertoast.showToast(
              msg: "No travel data available for this type/date");
        }
      } else {
        print(
            "Error fetching travel data: ${response.statusCode}, ${response.data}");
        Fluttertoast.showToast(msg: "Unable to fetch travel data");
      }
    } catch (e, s) {
      print("Exception fetching travel data: $e\n$s");
      Fluttertoast.showToast(msg: "Unable to fetch travel data");
    }

    return null;
  }

  Future<ExpenseData?> getExpense(String id) async {
    baseurl = await geturl();

    try {
      final dio = await _dio();

      final response = await dio.get(
        '$baseurl/api/method/mobile.mobile_env.app.get_expense',
        queryParameters: {'name': id},
      );

      if (response.statusCode == 200) {
        return ExpenseData.fromJson(response.data["data"]);
      }

      _showToast("Unable to load expense");
      return null;
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }

  /// -------------------------------
  /// UPLOAD DOCUMENT
  /// -------------------------------
  Future<Attachments?> uploadDocs(File? file) async {
    if (file == null) return null;

    try {
      final dio = await _dio();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: generateUniqueFileName(file),
        ),
      });

      final response = await dio.post(
        apiUploadFilePost,
        data: formData,
      );

      if (response.statusCode == 200) {
        return Attachments.fromJson(response.data["message"]);
      }
    } catch (e) {
      _log.e(e);
    }
    return null;
  }

  /// -------------------------------
  /// DELETE DOCUMENT
  /// -------------------------------
  Future<bool> deleteDoc(String name) async {
    baseurl = await geturl();

    try {
      final dio = await _dio();

      final response = await dio.delete(
        '$baseurl/api/resource/File/$name',
      );

      return response.statusCode == 202;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  /// -------------------------------
  /// HELPERS
  /// -------------------------------
  void _handleDioError(DioException e) {
    final msg = e.response?.data["message"]?.toString() ??
        e.response?.data["exception"]?.toString() ??
        "Something went wrong";

    _showToast(msg, success: false);
    _log.e(e.response);
  }

  void _showToast(String msg, {bool success = false}) {
    Fluttertoast.showToast(
      gravity: ToastGravity.BOTTOM,
      msg: msg,
      textColor: const Color(0xFFFFFFFF),
      backgroundColor:
          success ? const Color(0xFF006C50) : const Color(0xFFBA1A1A),
    );
  }
}
