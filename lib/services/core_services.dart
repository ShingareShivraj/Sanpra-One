import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/model/user_model.dart';
import 'package:logger/logger.dart';
import '../constants.dart';

class CoreServices{
  Future<List<User>> fetchRole() async {
    baseurl =  await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
          '$baseurl/api/method/mobile.mobile_env.app.get_user_document',
          options: Options(
            method: 'GET',
            headers: {'Authorization': await getTocken()},
          ),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(json.encode(response.data));
        List<User> caneList = List.from(jsonData['data'])
            .map<User>((data) => User.fromJson(data))
            .toList();
        return caneList;
      } else {
        Fluttertoast.showToast(msg: "Unable to fetch holidays");
        return [];
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(gravity:ToastGravity.BOTTOM,msg: 'Error: ${e.response!.data["exception"].toString().split(":").elementAt(1).trim()} ',textColor:const Color(0xFFFFFFFF),backgroundColor: const Color(0xFFBA1A1A),);
      Logger().e(e);
      return [];
    }
  }

}