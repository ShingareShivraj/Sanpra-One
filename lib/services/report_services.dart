import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/sales_person_commission.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/Sales Person target model.dart';
import '../model/sale_person_transaction_summary.dart';

class ReportServices {
  Future<List<SalesPersonWiseTransaction>> fetchTransactionSummary() async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/method/mobile.mobile_env.app.transaction_report',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<SalesPersonWiseTransaction> caneList = List.from(jsonData['data'])
            .map<SalesPersonWiseTransaction>(
                (data) => SalesPersonWiseTransaction.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch orders");
        return [];
      }
    } on DioException catch (e) {
      Logger().e(e.response?.data);
      Fluttertoast.showToast(msg: "Unauthorized Orders!");
      return [];
    }
  }

  Future<List<SalesPersonWiseCommission>> fetchCommissionSummary() async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/method/mobile.mobile_env.app.sales_person_commission_report',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<SalesPersonWiseCommission> caneList = List.from(jsonData['data'])
            .map<SalesPersonWiseCommission>(
                (data) => SalesPersonWiseCommission.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch orders");
        return [];
      }
    } on DioException catch (e) {
      Logger().e(e.response?.data);
      Fluttertoast.showToast(msg: "Unauthorized Orders!");
      return [];
    }
  }

  Future<List<SalesPersonWiseTarget>> fetchTarget() async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/method/mobile.mobile_env.app.target_variance_report',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<SalesPersonWiseTarget> caneList = List.from(jsonData['data'])
            .map<SalesPersonWiseTarget>(
                (data) => SalesPersonWiseTarget.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch orders");
        return [];
      }
    } on DioException catch (e) {
      Logger().e(e.response?.data);
      Fluttertoast.showToast(msg: "Unauthorized Orders!");
      return [];
    }
  }
}
