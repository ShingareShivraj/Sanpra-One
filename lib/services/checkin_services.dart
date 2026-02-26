import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../model/gelocation_model.dart';

class CheckinServices {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> addlocation(GeolocationModel designation) async {
    baseurl =  await geturl();
    var data = json.encode({
      "data": designation,
    });

    try {
      var dio = Dio();
      var response = await dio.request(
        'http://mobilecrm.erpdata.in/api/resource/Employee Location',
        options: Options(
          method: 'POST',
          headers: {'Authorization': await getTocken()},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        final SharedPreferences preferences = await _prefs;
        String name = response.data['data']['name'].toString();
        Fluttertoast.showToast(msg: "location Added Successfully");
        preferences.setString('locationid', name);

        return true;
      } else {
        Fluttertoast.showToast(msg: "UNABLE TO add location!");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error accoured $e ");
      Logger().e(e);
    }
    return false;
  }

  Future<bool> updatelocation(GeolocationModel designation) async {
    baseurl =  await geturl();
    var data = json.encode({
      "data": designation,
    });

    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/resource/Employee Location/${designation.name.toString()}',
        options: Options(
          method: 'PUT',
          headers: {'Authorization': await getTocken()},
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: "location updated Successfully");
        return true;
      } else {
        Fluttertoast.showToast(msg: "UNABLE TO update location!");
        return false;
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error accoured $e ");
      Logger().e(e);
    }
    return false;
  }

  Future<GeolocationModel?> getmember(String id) async {
    baseurl =  await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/method/mobile.mobile_env.location.getLocation',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Logger().i(response.data["data"]);
        return GeolocationModel.fromJson(response.data["data"]);
      } else {
        // print(response.statusMessage);
        return null;
      }
    } catch (e) {
      Logger().i(e);
      // Fluttertoast.showToast(msg: "Error while fetching location");
    }
    return null;
  }
}
