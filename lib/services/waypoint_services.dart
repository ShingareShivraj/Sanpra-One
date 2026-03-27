import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants.dart';

class WaypointServices {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
  ));

  final Logger _log = Logger();

  Future<String> _getBaseUrl() async => await geturl();
  Future<String> _getToken() async => await getTocken();

  /// ================= FETCH EMPLOYEE LOCATION =================
  Future<EmployeeLocation?> fetchEmployeeLocations({
    required String user,
    required String date,
  }) async {
    try {
      final baseUrl = await _getBaseUrl();
      final token = await _getToken();
      final url =
          "$baseUrl/api/method/mobile.mobile_env.location.get_user_locations";
      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': token}),
        data:{
          "date":date,
          "user":user
        }
      );

      if (response.statusCode == 200) {

        return EmployeeLocation.fromJson(response.data["data"]);
      }
    } on DioException catch (e) {
      _log.e(e.response);
      _handleError(e, message: "Failed to fetch locations");
    } catch (e, st) {
      _log.e("Unexpected error: $e", stackTrace: st);
    }
    return null;
  }

  /// ================= ROUTE API =================
  Future<List<dynamic>> getRoute(List<List<double>> coordinates) async {
    const apiKey =
        "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjYzZmFlMDY1Zjg2ODRjYTY4NDg2M2VjZDZlYTUwODBjIiwiaCI6Im11cm11cjY0In0=";

    try {
      final url =
          "https://api.openrouteservice.org/v2/directions/driving-car";

      final response = await _dio.post(
        url,
        data: {
          "coordinates": coordinates,
        },
        options: Options(
          headers: {
            "Authorization": apiKey,
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data["routes"] != null) {
        return response.data["routes"];
      }
    } on DioException catch (e) {
      _handleError(e, message: "Route fetch failed");
    } catch (e, st) {
      _log.e("Route error: $e", stackTrace: st);
    }
    return [];
  }

  /// ================= ERROR HANDLER =================
  void _handleError(DioException e, {String? message}) {
    String errorMsg = "Something went wrong";

    try {
      if (e.response?.data is Map &&
          e.response?.data["exception"] != null) {
        errorMsg =
            e.response!.data.toString().split(":").last.trim();
      } else if (e.message != null) {
        errorMsg = e.message!;
      }
    } catch (_) {}

    _log.e("❌ Dio Error: $errorMsg");
  }
}


class EmployeeLocation {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? user;
  String? date;
  String? myLocation;
  double? distance;
  String? doctype;
  List<LocationTable>? locationTable;

  EmployeeLocation(
      {this.name,
        this.owner,
        this.creation,
        this.modified,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.user,
        this.date,
        this.myLocation,
        this.distance,
        this.doctype,
        this.locationTable});

  EmployeeLocation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    user = json['user'];
    date = json['date'];
    myLocation = json['my_location'];
    distance = json['distance'];
    doctype = json['doctype'];
    if (json['location_table'] != null) {
      locationTable = <LocationTable>[];
      json['location_table'].forEach((v) {
        locationTable!.add(new LocationTable.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    data['modified'] = this.modified;
    data['modified_by'] = this.modifiedBy;
    data['docstatus'] = this.docstatus;
    data['idx'] = this.idx;
    data['user'] = this.user;
    data['date'] = this.date;
    data['my_location'] = this.myLocation;
    data['distance'] = this.distance;
    data['doctype'] = this.doctype;
    if (this.locationTable != null) {
      data['location_table'] =
          this.locationTable!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationTable {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? datetime;
  String? address;
  String? referenceName;
  String? referenceType;
  String? latitude;
  String? longitude;
  double? accuracy;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  LocationTable(
      {this.name,
        this.owner,
        this.creation,
        this.modified,
        this.modifiedBy,
        this.docstatus,
        this.idx,
        this.datetime,
        this.address,
        this.referenceName,
        this.referenceType,
        this.latitude,
        this.longitude,
        this.accuracy,
        this.parent,
        this.parentfield,
        this.parenttype,
        this.doctype});

  LocationTable.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    datetime = json['datetime'];
    address = json['address'];
    referenceName = json['reference_name'];
    referenceType = json['reference_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    accuracy = json['accuracy'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['owner'] = this.owner;
    data['creation'] = this.creation;
    data['modified'] = this.modified;
    data['modified_by'] = this.modifiedBy;
    data['docstatus'] = this.docstatus;
    data['idx'] = this.idx;
    data['datetime'] = this.datetime;
    data['address'] = this.address;
    data['reference_name'] = this.referenceName;
    data['reference_type'] = this.referenceType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['accuracy'] = this.accuracy;
    data['parent'] = this.parent;
    data['parentfield'] = this.parentfield;
    data['parenttype'] = this.parenttype;
    data['doctype'] = this.doctype;
    return data;
  }
}

