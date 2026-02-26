import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/create_customer_model.dart';
import '../screens/customer_screen/Update_Customer/update_customer_model.dart';

class AddCustomerServices {
  final Logger _logger = Logger();
  Dio? _dio;

  // ----------------------------
  // DIO INITIALIZATION
  // ----------------------------
  Future<Dio> _getDio() async {
    if (_dio != null) return _dio!;

    baseurl = await geturl();

    _dio = Dio(
      BaseOptions(
        baseUrl: baseurl,
        headers: {
          'Authorization': await getTocken(),
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    return _dio!;
  }

  // ----------------------------
  // COMMON ERROR HANDLER
  // ----------------------------
  void _handleDioError(DioException e) {
    final message = e.response?.data?["message"] ??
        e.response?.data?["exception"] ??
        e.message ??
        "Something went wrong";

    Fluttertoast.showToast(
      gravity: ToastGravity.BOTTOM,
      msg: message.toString(),
      textColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFFBA1A1A),
    );

    _logger.e(e);
  }

  // ----------------------------
  // FETCH CUSTOMER GROUP
  // ----------------------------
  Future<List<String>> fetchCustomerGroup() async {
    try {
      final dio = await _getDio();

      final res = await dio.get(
        '/api/resource/Customer Group',
        queryParameters: {"limit_page_length": 999},
      );

      return (res.data["data"] as List)
          .map((e) => e["name"].toString())
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    }
  }

  // ----------------------------
  // FETCH TERRITORY
  // ----------------------------

// ...

  Future<List<String>> fetchTerritory() async {
    try {
      final dio = await _getDio();

      final res = await dio.get(
        '/api/resource/Territory',
        queryParameters: {
          "limit_page_length": 999,
          "filters": jsonEncode([
            ["Territory", "is_group", "=", 0],
          ]),
          // optional: fetch only needed field
          // "fields": jsonEncode(["name"]),
        },
      );

      return (res.data["data"] as List)
          .map((e) => e["name"].toString())
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    }
  }


  // ----------------------------
  // CREATE CUSTOMER
  // ----------------------------
  Future<bool> createCustomer(CreateCustomer customer) async {
    try {
      final dio = await _getDio();

      final res = await dio.post(
        '/api/method/mobile.mobile_env.customer.create_customer',
        data: customer.toJson(),
      );

      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: res.data["message"] ?? "Customer created",
        textColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFF006C50),
      );

      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  // ----------------------------
  // GET CUSTOMER DETAILS
  // ----------------------------
  Future<GetCustomer?> getCustomerDetails(String id) async {
    try {
      final dio = await _getDio();

      final res = await dio.get(
        '/api/method/mobile.mobile_env.customer.get_customer_details',
        queryParameters: {
          "customer": id, // Dio auto-encodes
        },
      );

      return GetCustomer.fromJson(res.data["data"]);
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }

  // ----------------------------
  // GET CUSTOMER (EDIT MODE)
  // ----------------------------
  Future<CreateCustomer?> getCustomer(String id) async {
    try {
      final dio = await _getDio();

      final res = await dio.get(
        '/api/method/mobile.mobile_env.customer.get_customer',
        queryParameters: {
          "name": id,
        },
      );

      return CreateCustomer.fromJson(res.data["data"]);
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }
}
