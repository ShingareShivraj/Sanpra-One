import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class GeolocationService {
  final Logger _logger = Logger();
  static const _latKey = "last_lat";
  static const _lngKey = "last_lng";
  static const _accuracyKey = "last_accuracy";

  /// Save location locally
  Future<void> cacheLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, position.latitude);
    await prefs.setDouble(_lngKey, position.longitude);
    await prefs.setDouble(_accuracyKey, position.accuracy);
  }

  /// Get cached location
  Future<Position?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    final accuracy = prefs.getDouble(_accuracyKey);

    if (lat == null || lng == null) return null;

    return Position(
      latitude: lat,
      longitude: lng,
      accuracy: accuracy ?? 999,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
    );
  }

  /// Validate accuracy
  bool isAccuracyAcceptable(Position position, {double maxMeters = 50}) {
    return position.accuracy <= maxMeters;
  }

  /// Determines current position with required permissions.
  Future<Position?> determinePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }

      // Request permissions
      if (await _requestPermission(Permission.location) != true) {
        throw Exception('Location permission denied.');
      }

      if (await _requestPermission(Permission.notification) != true) {
        throw Exception('Notification permission denied.');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _logger.e('Determine Position Error', error: e);
      return null;
    }
  }

  /// Requests a single permission
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  /// Get Placemark from Position
  Future<Placemark?> getPlaceMarks(Position? position) async {
    if (position == null) return null;

    try {
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      return placemarks.isNotEmpty ? placemarks.first : null;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Location data not available');
      _logger.e('Placemark Error', error: e);
      return null;
    }
  }

  /// Get address string from coordinates
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      return '${p.street}, ${p.subLocality}, ${p.locality}, '
          '${p.administrativeArea}, ${p.country}, ${p.postalCode}';
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get address from coordinates');
      _logger.e('Address Error', error: e);
      return null;
    }
  }

  /// Calculate driving distance between two points using Mappls API
  Future<double?> calculateDistance(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) async {
    const apiKey = '1cfcdeaf26352898f9975a577da9fd30';
    final url =
        'https://apis.mappls.com/advancedmaps/v1/$apiKey/distance_matrix/driving/'
        '$originLng,$originLat;$destinationLng,$destinationLat?rtype=0&region=IND';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch distance: ${response.reasonPhrase}');
      }

      final data = json.decode(response.body);
      return data['results']['distances'][0][1]?.toDouble();
    } catch (e) {
      _logger.e('Distance Calculation Error', error: e);
      throw Exception('Error calculating distance: $e');
    }
  }

  Map<String, dynamic> buildLocationPayload(Map<String, dynamic> args) {
    return {
      "date": args["date"],
      "location": [
        {
          "latitude": args["lat"],
          "longitude": args["lng"],
          "accuracy": args["accuracy"],
          "timestamp": args["timestamp"],
        }
      ]
    };
  }

  Future<bool> employeeLocation(Position position) async {
    try {
      final baseUrl = await geturl();
      final token = await getTocken();

      final payload = {
        "date": DateFormat("yyyy-MM-dd").format(DateTime.now()),
        "location": [
          {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "accuracy": position.accuracy ?? 999,
            "datetime": DateTime.now().toIso8601String(),
          }
        ]
      };

      final dio = Dio();

      final response = await dio.post(
        "$baseUrl/api/method/mobile.mobile_env.location.user_location",
        options: Options(
          headers: {
            "Authorization": token,
            "Content-Type": "application/json",
          },
        ),
        data: payload,
      );

      Logger().i(response.data["message"]);
      return response.statusCode == 200;
    } on DioException catch (e) {
      Logger().e(e.response?.data ?? e.message);
      return false;
    } catch (e) {
      Logger().e(e);
      return false;
    }
  }
}
