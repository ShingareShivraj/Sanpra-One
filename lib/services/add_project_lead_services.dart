import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocation/screens/Marketing%20Material%20Issue/add_marketing/add_marketing_viewmodel.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/project_details.dart';
import '../model/project_lead_model.dart';
import '../screens/Marketing Material Issue/list_marketing/list_marketing_viewmodel.dart';

class ProjectLeadService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  Future<List<ProjectLead>> getAllProjectLead() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Project Lead',
        queryParameters: {
          'fields': '["name","site_status","contact_person","territory"]',
          'limit_page_length': 100,
          'order_by': 'modified desc',
        },
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      print(response.realUri);
      return (response.data['data'] as List)
          .map((json) => ProjectLead.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to fetch retailer list');
      return [];
    }
  }

  Future<List<String>> fetchCustomer() async {
    baseurl = await geturl();
    try {
      final response = await _dio.get(
        '$baseurl/api/method/mobile.mobile_env.order.get_customer_list',
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      final List<dynamic> dataList = response.data["message"];
      return dataList.map((e) => e.toString()).toList();
    } catch (e) {
      _handleError(e, "Unable to fetch customers");
      return [];
    }
  }

  Future<ProjectLeadDetails?> leadDetails() async {
    try {
      baseurl = await geturl();
      final url =
          '$baseurl/api/method/mobile.mobile_env.lead.project_lead_details';
      final token = await getTocken();

      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200 && response.data["data"] != null) {
        final leadDetails = ProjectLeadDetails.fromJson(response.data["data"]);
        _logger.i("✅ Lead details fetched successfully");
        return leadDetails;
      }
    } on DioException catch (e) {
      _handleError(e, "Failed to create order");
    } catch (e, st) {
      _logger.e("Unexpected error fetching lead details: $e", stackTrace: st);
    }
    return null;
  }

  Future<bool> addProjectLead(ProjectLead orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/resource/Project Lead',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: response.data['message'].toString());
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<bool> updateProjectLead(ProjectLead orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.put(
        '$baseurl/api/resource/Project Lead/${orderDetails.name}',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: response.data['message'].toString());
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<ProjectLead?> getProjectLead(String id) async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/resource/Project Lead/$id',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Logger().i(ProjectLead.fromJson(response.data["data"]));
        return ProjectLead.fromJson(response.data["data"]);
      } else {
        return null;
      }
    } catch (e) {
      _handleError(e, "Failed to create order");
      return null;
    }
  }

  Future<List<ListMarketingMaterialIssue>> getAllIssue() async {
    baseurl = await geturl();

    try {
      final response = await _dio.get(
        '$baseurl/api/resource/Marketing Material Issue',
        queryParameters: {
          'fields': '["name","customer","date","total_qty","workflow_state"]',
          'limit': 999,
          'order_by': 'modified desc',
        },
        options: Options(headers: {'Authorization': await getTocken()}),
      );

      print(response.realUri);

      return (response.data['data'] as List)
          .map((json) => ListMarketingMaterialIssue.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to fetch Marketing Material Issue');
      return [];
    }
  }

  Future<MerchandiseDetails?> marketingDetails() async {
    try {
      baseurl = await geturl();
      final url =
          '$baseurl/api/method/mobile.mobile_env.lead.marketing_details';
      final token = await getTocken();

      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200 && response.data["data"] != null) {
        final leadDetails = MerchandiseDetails.fromJson(response.data["data"]);
        _logger.i("✅ Lead details fetched successfully");
        return leadDetails;
      }
    } on DioException catch (e) {
      _handleError(e, "Failed to create order");
    } catch (e, st) {
      _logger.e("Unexpected error fetching lead details: $e", stackTrace: st);
    }
    return null;
  }

  Future<bool> addIssue(MarketingMaterialIssue orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.post(
        '$baseurl/api/resource/Marketing Material Issue',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: response.data['message'].toString());
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<bool> updateIssue(MarketingMaterialIssue orderDetails) async {
    baseurl = await geturl();
    try {
      final response = await _dio.put(
        '$baseurl/api/resource/Marketing Material Issue/${orderDetails.name}',
        data: json.encode(orderDetails),
        options: Options(headers: {'Authorization': await getTocken()}),
      );
      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: response.data['message'].toString());
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e, "Failed to create order");
      return false;
    }
  }

  Future<MarketingMaterialIssue?> getIssue(String id) async {
    baseurl = await geturl();
    try {
      var dio = Dio();
      var response = await dio.request(
        '$baseurl/api/resource/Marketing Material Issue/$id',
        options: Options(
          method: 'GET',
          headers: {'Authorization': await getTocken()},
        ),
      );

      if (response.statusCode == 200) {
        Logger().i(ProjectLead.fromJson(response.data["data"]));
        return MarketingMaterialIssue.fromJson(response.data["data"]);
      } else {
        return null;
      }
    } catch (e) {
      _handleError(e, "Failed to create order");
      return null;
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

class MerchandiseDetails {
  List<String>? customer;
  List<MerchandiseItems>? merchandiseItems;

  MerchandiseDetails({this.customer, this.merchandiseItems});

  MerchandiseDetails.fromJson(Map<String, dynamic> json) {
    customer = json['customer'].cast<String>();
    if (json['merchandise_items'] != null) {
      merchandiseItems = <MerchandiseItems>[];
      json['merchandise_items'].forEach((v) {
        merchandiseItems!.add(new MerchandiseItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer'] = this.customer;
    if (this.merchandiseItems != null) {
      data['merchandise_items'] =
          this.merchandiseItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MerchandiseItems {
  String? name;
  String? uom;
  String? itemName;

  MerchandiseItems({this.name, this.uom, this.itemName});

  MerchandiseItems.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uom = json['uom'];
    itemName = json['item_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uom'] = this.uom;
    data['item_name'] = this.itemName;
    return data;
  }
}
