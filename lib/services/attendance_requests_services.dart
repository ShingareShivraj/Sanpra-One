import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/add_order_model.dart';
import '../model/attendance_request_model.dart';
import '../model/order_details_model.dart';
import '../screens/attendance_request/list_attendance_request/list_attendance_request_viewmodel.dart';

class AttendanceRequestsServices {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  Future<AddOrderModel?> getOrder(String id) async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Sales Order/$id',
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      return AddOrderModel.fromJson(response.data["data"]);
    } catch (e) {
      _handleError(e, "Error while fetching order");
      return null;
    }
  }

  Future<Masters?> masters() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/method/mobile.mobile_env.order.masters',
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      return Masters.fromJson(response.data["data"]);
    } catch (e) {
      _handleError(e, "Error while fetching masters");
      return null;
    }
  }

  Future<bool> delete(String? id) async {
    baseurl = await geturl();
    try {
      final response = await _dio.delete(
        '$baseurl/api/method/mobile.mobile_env.app.delete_attendance_request',
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
      return false;
    } catch (e, s) {
      _logger.e('Unexpected error in getLeaveTypes', error: e, stackTrace: s);
      return false;
    }
  }

  Future<List<AttendanceRequestModel>> getAttendanceRequests(
      int month, int year) async {
    baseurl = await geturl();
    var data = {'year': '$year', 'month': '$month'};
    try {
      var dio = Dio();
      var response = await dio.request(
          '$baseurl/api/method/mobile.mobile_env.app.get_attendance_request_list',
          options: Options(
            method: 'GET',
            headers: {'Authorization': await getTocken()},
          ),
          data: data);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<AttendanceRequestModel> caneList = List.from(jsonData["data"])
            .map<AttendanceRequestModel>(
                (data) => AttendanceRequestModel.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch request");
        return [];
      }
    } on DioException catch (e) {
      _handleError(e, "Failed to create order");
      return [];
    }
  }

  Future<bool> addRequest(AttendanceRequest orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/method/mobile.mobile_env.app.create_attendance_request',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<bool> closeOrder(String? name) async {
    baseurl = await geturl();

    try {
      final response = await _dio.put(
        '$baseurl/api/method/erpnext.selling.doctype.sales_order.sales_order.update_status',
        data: json.encode({"name": name, "status": "Closed"}),
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e, "Failed to close order");
      return false;
    }
  }

  Future<List<OrderDetailsModel>> orderDetails(
      AddOrderModel orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/method/mobile.mobile_env.order.prepare_order_totals',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      return List<OrderDetailsModel>.from(
        response.data["data"].map((e) => OrderDetailsModel.fromJson(e)),
      );
    } catch (e) {
      _handleError(e, "Unable to prepare order details");
      return [];
    }
  }

  void _handleError(dynamic error, String fallbackMessage) {
    if (error is DioException) {
      final message = error.response?.data ??
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
