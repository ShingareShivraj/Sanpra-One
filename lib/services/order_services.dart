import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/order_list_model.dart';
import '../screens/delivery_note/delivery_note_viewmodel.dart';
import '../screens/stock_screen/stock_screen.dart';

class OrderServices {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  /// Base fields used for all requests
  static const _fields =
      '["name","customer_name","transaction_date","grand_total","status","total_qty","set_warehouse","delivery_status","owner","delivery_date"]';

  /// Fetch all sales orders (most recent first)
  Future<List<OrderList>> fetchSalesOrder() async {
    try {
      final url = await _buildBaseUrl();

      final response = await _dio.get(
        '$url/api/resource/Sales Order',
        queryParameters: {
          'order_by': 'creation desc',
          'fields': _fields,
          'limit_page_length': '999'
        },
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return _parseOrderList(response.data['data']);
      } else {
        _showToast('Unable to fetch orders');
        return [];
      }
    } catch (e, stacktrace) {
      print(e.toString());
      _handleError(e, context: 'fetchSalesOrder', stack: stacktrace);
      return [];
    }
  }

  Future<List<OrderList>> fetchSelfOrder() async {
    try {
      final url = await _buildBaseUrl();

      final response = await _dio.get(
        '$url/api/method/mobile.mobile_env.order.get_self_orders_list',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return _parseOrderList(response.data['data']);
      } else {
        _showToast('Unable to fetch orders');
        return [];
      }
    } catch (e, stacktrace) {
      print(e.toString());
      _handleError(e, context: 'fetchSelfOrder', stack: stacktrace);
      return [];
    }
  }

  Future<List<OrderList>> fetchDistributorOrder() async {
    try {
      final url = await _buildBaseUrl();

      final response = await _dio.get(
        '$url/api/method/mobile.mobile_env.order.get_distributor_orders_list',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return _parseOrderList(response.data['data']);
      } else {
        _showToast('Unable to fetch orders');
        return [];
      }
    } catch (e, stacktrace) {
      print(e.toString());
      _handleError(e, context: 'fetchSelfOrder', stack: stacktrace);
      return [];
    }
  }


  Future<DeliveryNote?> getOrder(String id) async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Delivery Note/$id',
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        _logger.i(DeliveryNote.fromJson(response.data["data"]));
        return DeliveryNote.fromJson(response.data["data"]);
      } else {
        _showToast('Unable to fetch orders');
        return null;
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data.toString() ?? "Unexpected API error";
      _showToast(errorMsg, isError: true);
      _logger.e('DioException in filterFetchDeliveryNoteId ${e.stackTrace}');
      return null;
    } catch (e, stacktrace) {
      _handleError(e, context: 'filterFetchDeliveryNoteId', stack: stacktrace);
      return null;
    }
  }

  Future<List<DeliverNoteList>> filterFetchDeliveryNote() async {
    try {
      final url = await _buildBaseUrl();
      final response = await _dio.get(
        '$url/api/method/mobile.mobile_env.order.get_delivery_note_list',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return _parseNoteList(response.data['data']);
      } else {
        _showToast('Unable to fetch filtered orders');
        return [];
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data["message"]?.toString() ?? "Unexpected API error";
      _showToast(errorMsg, isError: true);
      _logger.e('DioException in filterFetchDeliveryNote ${e.stackTrace}');
      return [];
    } catch (e, stacktrace) {
      _handleError(e, context: 'filterFetchDeliveryNote', stack: stacktrace);
      return [];
    }
  }

  Future<List<ItemStock>> fetchStocks() async {
    try {
      final url = await _buildBaseUrl();

      // final queryParams = {
      //   'order_by': 'modified desc',
      //   'fields':
      //       '["name","customer_name","posting_date","grand_total","status","total_qty"]',
      //   'limit_page_length': '999'
      // };

      final response = await _dio.get(
        '$url/api/method/mobile.mobile_env.app.get_item_warehouse_stock',
        // queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return List<ItemStock>.from(
            response.data['data'].map((json) => ItemStock.fromJson(json)));
      } else {
        _showToast('Unable to fetch filtered orders');
        return [];
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data["message"]?.toString() ?? "Unexpected API error";
      _showToast(errorMsg, isError: true);
      _logger.e('DioException in stocks ${e.stackTrace}');
      return [];
    } catch (e, stacktrace) {
      _handleError(e, context: 'stocks', stack: stacktrace);
      return [];
    }
  }

  /// Fetch filtered sales orders
  Future<List<OrderList>> filterFetchSalesOrder(
      String customerName, String date) async {
    try {
      final url = await _buildBaseUrl();

      final List<List<String>> filters = [];
      if (customerName.isNotEmpty) {
        filters.add(["customer_name", "=", customerName]);
      }
      if (date.isNotEmpty) {
        filters.add(["transaction_date", "=", date]);
      }

      final queryParams = {
        'order_by': 'modified desc',
        'fields': _fields,
        'limit_page_length': '999',
        if (filters.isNotEmpty) 'filters': jsonEncode(filters),
      };

      final response = await _dio.get(
        '$url/api/resource/Sales Order',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      _logger.i('Filtered API URL: $url');
      _logger.i('Filters: $filters');

      if (response.statusCode == 200 && response.data['data'] != null) {
        return _parseOrderList(response.data['data']);
      } else {
        _showToast('Unable to fetch filtered orders');
        return [];
      }
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data["message"]?.toString() ?? "Unexpected API error";
      _showToast(errorMsg, isError: true);
      _logger.e('DioException in filterFetchSalesOrder ${e.stackTrace}');
      return [];
    } catch (e, stacktrace) {
      _handleError(e, context: 'filterFetchSalesOrder', stack: stacktrace);
      return [];
    }
  }

  // === Helpers ===

  /// Parse API response into a list of OrderList models
  List<OrderList> _parseOrderList(dynamic rawData) {
    return List<OrderList>.from(
      rawData.map((json) => OrderList.fromJson(json)),
    );
  }

  List<DeliverNoteList> _parseNoteList(dynamic rawData) {
    return List<DeliverNoteList>.from(
      rawData.map((json) => DeliverNoteList.fromJson(json)),
    );
  }

  /// Fetch dynamic base URL
  Future<String> _buildBaseUrl() async => await geturl();

  /// Toast utility
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      backgroundColor: isError ? const Color(0xFFBA1A1A) : Colors.black87,
    );
  }

  /// Unified error handling
  void _handleError(Object e, {required String context, StackTrace? stack}) {
    _logger.e('Error in $context: $e');
    _showToast('Something went wrong while fetching data.', isError: true);
  }
}
