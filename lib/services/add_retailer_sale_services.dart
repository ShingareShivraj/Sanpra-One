import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/add_retailer_sale_model.dart';
import 'package:geolocation/model/retailer_model.dart';
import 'package:logger/logger.dart';

import '../constants.dart';

class RetailerSaleService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  Future<List<Retailer>> fetchRetailers() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Retailer Master',
        queryParameters: {
          'fields': '["name","name1"]',
          'limit_page_length': 100,
          'order_by': 'modified desc',
        },
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      return List<Retailer>.from(
        response.data["data"].map((e) => Retailer.fromJson(e)),
      );
    } catch (e) {
      _handleError(e, "Unable to fetch customer details");
      return [];
    }
  }

  Future<List<RetailerSale>> getAllRetailersSale() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Retailer Sale',
        queryParameters: {
          'fields': '["name","name1","date","qty_total","amount_total"]',
          'limit_page_length': 100,
          'order_by': 'modified desc',
        },
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      print(response.realUri);
      return (response.data['data'] as List)
          .map((json) => RetailerSale.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to fetch retailer list');
      return [];
    }
  }

  Future<List<Items>> getAllItems() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Item',
        queryParameters: {
          'fields': '["name","item_name","item_code","stock_uom as uom"]',
          'limit_page_length': 100,
          'order_by': 'modified desc',
        },
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      return (response.data['data'] as List)
          .map((json) => Items.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to fetch retailer list');
      return [];
    }
  }

  Future<bool> addRetailerSale(RetailerSale orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/resource/Retailer Sale',
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
