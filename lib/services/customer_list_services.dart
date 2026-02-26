import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/customer_list_model.dart';
import 'package:logger/logger.dart';

import '../constants.dart';

class CustomerListService {
  Future<List<CustomerList>> fetchCustomerList() async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.get(
        '$baseurl/api/method/mobile.mobile_env.customer.filter_customer_list',
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = response.data;
        List<CustomerList> customerList = List.from(jsonData['data'])
            .map<CustomerList>((data) => CustomerList.fromJson(data))
            .toList();
        return customerList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch customers");
        return [];
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: 'Error: ${e.response?.data["message"].toString()} ',
        textColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFBA1A1A),
      );
      Logger().e(e);
      return [];
    }
  }

  Future<List<CustomerList>> fetchFilterCustomer(
      String territory, String customerName) async {
    baseurl = await geturl();
    try {
      var dio = Dio();

      // 🔹 Build query parameters
      final queryParams = {
        if (customerName.isNotEmpty) "customer_name": customerName,
        if (territory.isNotEmpty) "territory": territory,
      };

      var response = await dio.get(
        '$baseurl/api/method/mobile.mobile_env.customer.filter_customer_list',
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = response.data;
        List<CustomerList> customerList = List.from(jsonData['data'])
            .map<CustomerList>((data) => CustomerList.fromJson(data))
            .toList();
        return customerList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch customers");
        return [];
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: 'Error: ${e.response?.data["message"].toString()} ',
        textColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFBA1A1A),
      );
      Logger().e(e);
      return [];
    }
  }

  Future<List<String>> getcustomer() async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/method/mobile.mobile_env.customer.filter_customer_list',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        var jsonData = json.encode(response.data);
        Map<String, dynamic> jsonDataMap = json.decode(jsonData);
        List<dynamic> dataList = jsonDataMap["data"];
        Logger().i(dataList);
        List<String> namesList =
            dataList.map((item) => item["name"].toString()).toList();
        return namesList;
      } else {
        Fluttertoast.showToast(msg: "UNABLE TO get notes!");
        return [];
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        gravity: ToastGravity.BOTTOM,
        msg: 'Error: ${e.response!.data["message"].toString()} ',
        textColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFFBA1A1A),
      );
      Logger().e(e);
    }
    return [];
  }
}
