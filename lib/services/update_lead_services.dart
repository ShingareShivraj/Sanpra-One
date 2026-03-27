import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../constants.dart';
import '../model/notes_list.dart';

class UpdateLeadServices {
  final Logger _log = Logger();

  late Dio _dio;

  UpdateLeadServices() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ));

    /// 🔥 INTERCEPTOR (AUTO TOKEN)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getTocken();
          final baseurl = await geturl();

          options.headers['Authorization'] = token;
          options.baseUrl = baseurl;

          _log.i("➡️ ${options.method} ${options.path}");

          return handler.next(options);
        },
        onError: (e, handler) {
          _handleError(e);
          return handler.next(e);
        },
      ),
    );
  }

  /// ================= COMMON ERROR =================
  void _handleError(DioException e, {String? msg}) {
    String error = "Something went wrong";

    try {
      if (e.response?.data != null) {
        final data = e.response!.data;

        if (data["exception"] != null) {
          error = data["exception"].toString().split(":").last.trim();
        } else if (data["message"] != null) {
          error = data["message"].toString();
        }
      }
    } catch (_) {}

    _log.e("❌ $error");

    Fluttertoast.showToast(
      msg: msg ?? error,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// ================= GET NOTES =================
  Future<List<NotesList>> getnotes(String leadname) async {
    try {
      final response = await _dio.get(
        '/api/method/mobile.mobile_env.app.get_data_from_notes',
        queryParameters: {'doc_name': leadname},
      );

      if (response.statusCode == 200) {
        final List data = response.data["data"] ?? [];

        return data
            .map<NotesList>((e) => NotesList.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      _handleError(e, msg: "Failed to fetch notes");
    }

    return [];
  }

  /// ================= DELETE NOTE =================
  Future<bool> deletenotes(String leadname, int index) async {
    try {
      final response = await _dio.post(
        '/api/method/mobile.mobile_env.app.delete_note_in_lead',
        data: {
          'doc_name': leadname,
          'row_id': index.toString(),
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: response.data["message"]);
        return true;
      }
    } on DioException catch (e) {
      _handleError(e, msg: "Failed to delete note");
    }

    return false;
  }

  /// ================= ADD NOTE =================
  Future<bool> addnotes(String leadname, dynamic note) async {
    try {
      final response = await _dio.post(
        '/api/method/mobile.mobile_env.app.add_note_in_lead',
        data: {
          'doc_name': leadname,
          'note': note,
        },
      );

      if (response.statusCode == 200) {
        _log.i(response.data["message"]);
        return true;
      }
    } on DioException catch (e) {
      _handleError(e, msg: "Failed to add note");
    }

    return false;
  }

  /// ================= CHANGE STATUS =================
  Future<bool> changestatus(String leadname, String type) async {
    try {
      final response = await _dio.post(
        '/api/method/mobile.mobile_env.app.change_status',
        data: {
          'doc_name': leadname,
          'type': type,
        },
      );

      if (response.statusCode == 200) {
        _log.i(response.data["message"]);
        return true;
      }
    } on DioException catch (e) {
      _handleError(e, msg: "Failed to change status");
    }

    return false;
  }
}