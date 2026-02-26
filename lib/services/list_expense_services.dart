import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/expenselist_model.dart';

class ExpenseServices{
  Future<List<Expenselist>> fetchexpense(int month,int year) async {
    baseurl =  await geturl();
    var data = {
      'year': '${year}',
      'month': '${month}'
    };
    try {
      var dio = Dio();
      var response = await dio.request(
          '$baseurl/api/method/mobile.mobile_env.app.get_expense_list',
          options: Options(
            method: 'GET',
            headers: {'Authorization': await getTocken()},
          ),
data: data
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<Expenselist> caneList = List.from(jsonData["data"])
            .map<Expenselist>((data) => Expenselist.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch items");
        return [];
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.response?.data['message'].toString()}",
        backgroundColor: Color(0xFFBA1A1A),
        textColor: Color(0xFFFFFFFF),
      );
      Logger().e(e.response?.data['message'].toString());
      return [];
    }
  }

}