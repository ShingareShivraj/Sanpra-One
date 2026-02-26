import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/retailer_model.dart';
import 'package:logger/logger.dart';

import '../constants.dart';

class RetailerServices {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  Future<List<Retailer>> getAllRetailers() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Retailer Master',
        queryParameters: {
          'fields':
              '["name","name1","mobile","email","city","pincode","address_line_1"]',
          'limit_page_length': 100,
          'order_by': 'modified desc',
        },
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      return (response.data['data'] as List)
          .map((json) => Retailer.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to fetch retailer list');
      return [];
    }
  }

  Future<Retailer?> getRetailer(String id) async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Retailer Master/$id',
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      return Retailer.fromJson(response.data["data"]);
    } catch (e) {
      _handleError(e, "Error while fetching order");
      return null;
    }
  }

  Future<bool> addRetailer(Retailer orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/resource/Retailer Master',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      // Fluttertoast.showToast(msg: response.data['message'].toString());
      return true;
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<bool> updateRetailer(Retailer orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.put(
        '$baseurl/api/resource/Retailer Master/${orderDetails.name}',
        data: orderDetails.toJson(),
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      // Fluttertoast.showToast(msg: response.data['message'].toString());
      return true;
    } catch (e) {
      _handleError(e, "Failed to update order");
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

      _logger.e("DioException: $message");
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
