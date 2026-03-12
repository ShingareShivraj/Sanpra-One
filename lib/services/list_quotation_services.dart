import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import '../constants.dart';
import '../model/addquotation_model.dart';
import '../model/quotation_list_model.dart';

class QuotationServices {

  final Dio _dio = Dio();
  final Logger _logger = Logger();

  Future<Map<String, String>> _headers() async {
    return {
      "Authorization": await getTocken(),
    };
  }

  Future<String> _baseUrl() async {
    return await geturl();
  }

  /// ---------------- Fetch All Quotations ----------------
  Future<List<QuotationList>> fetchquotation() async {
    try {
      final baseurl = await _baseUrl();

      final response = await _dio.get(
        "$baseurl/api/resource/Quotation",
        queryParameters: {
          "order_by": "modified desc",
          "fields":
          '["name","customer_name","transaction_date","grand_total","status","total_qty","quotation_to"]'
        },
        options: Options(headers: await _headers()),
      );

      if (response.statusCode == 200) {
        List data = response.data["data"];

        return data
            .map<QuotationList>((e) => QuotationList.fromJson(e))
            .toList();
      }

      Fluttertoast.showToast(msg: "Unable to fetch Quotation");
      return [];
    } catch (e) {
      _logger.e(e);
      Fluttertoast.showToast(msg: "Unauthorized Quotation!");
      return [];
    }
  }

  /// ---------------- Filter Quotations ----------------
  Future<List<QuotationList>> fetchfilterquotation(
      String quotationTo,
      String customerName,
      ) async {

    try {
      final baseurl = await _baseUrl();

      List filters = [];

      if (customerName.isNotEmpty) {
        filters.add(["customer_name", "=", customerName]);
      }

      if (quotationTo.isNotEmpty) {
        filters.add(["quotation_to", "=", quotationTo]);
      }

      final response = await _dio.get(
        "$baseurl/api/resource/Quotation",
        queryParameters: {
          "order_by": "modified desc",
          "fields":
          '["name","customer_name","transaction_date","grand_total","status","total_qty","quotation_to"]',
          if (filters.isNotEmpty) "filters": filters
        },
        options: Options(headers: await _headers()),
      );

      if (response.statusCode == 200) {
        List data = response.data["data"];

        return data
            .map<QuotationList>((e) => QuotationList.fromJson(e))
            .toList();
      }

      Fluttertoast.showToast(msg: "Unable to fetch quotations");
      return [];

    } on DioException catch (e) {

      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: 'Error: ${e.response?.data["message"]}',
      );

      _logger.e(e);
      return [];
    }
  }

  /// ---------------- Customer List ----------------
  Future<List<String>> getcustomer() async {

    try {
      final baseurl = await _baseUrl();

      final response = await _dio.get(
        "$baseurl/api/method/mobile.mobile_env.quotation.filter_customer_list",
        options: Options(headers: await _headers()),
      );

      if (response.statusCode == 200) {

        List data = response.data["data"];

        return data
            .map<String>((item) => item["customer_name"].toString())
            .toList();
      }

      Fluttertoast.showToast(msg: "Unable to fetch customers");
      return [];

    } on DioException catch (e) {

      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: e.response?.data["exception"]
            ?.toString()
            .split(":")
            .last
            .trim() ?? "Error",
      );

      _logger.e(e);
      return [];
    }
  }

  /// ---------------- Items ----------------
  Future<List<Items>> fetchitems() async {

    try {

      final baseurl = await _baseUrl();

      final response = await _dio.get(
        "$baseurl/api/method/mobile.mobile_env.quotation.get_item_list",
        options: Options(headers: await _headers()),
      );

      if (response.statusCode == 200) {

        List data = response.data["data"];

        return data
            .map<Items>((item) => Items.fromJson(item))
            .toList();
      }

      Fluttertoast.showToast(msg: "Unable to fetch items");
      return [];

    } catch (e) {

      _logger.e(e);
      Fluttertoast.showToast(msg: e.toString());
      return [];
    }
  }
}