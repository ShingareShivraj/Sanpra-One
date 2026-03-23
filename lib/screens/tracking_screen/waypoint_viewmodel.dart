import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'company_auth.dart';
import '../../../constants.dart';


class WaypointData {
  final LatLng position;
  final String referenceType;
  final String referenceName;
  final String description;

  WaypointData({
    required this.position,
    required this.referenceType,
    required this.referenceName,
    required this.description,
  });
}

class WaypointViewModel extends BaseViewModel {
  final String user;

  WaypointViewModel(this.user);

  List<WaypointData> points = [];
  List<Marker> markers = [];
  MapController mapController = MapController();
  LatLng? currentPosition;
  List<WaypointData> waypoints = [];   // from Frappe
  List<LatLng> routePoints = [];
  Marker? movingMarker;
  List<Marker> staticMarkers = [];
  double totalDistance = 0;
  bool isAnimating=false;
  bool stopAnimation=false;
  DateTime selectedDate = DateTime.now();
  double animationSpeed = 2.5;
  LatLng initialPosition = const LatLng(16.8512, 74.6126);
  bool isMapReady = false;
  // ================= INIT =================
  Future<void> init() async {
    await fetchData();
  }

  // ================= API =================
  Future<void> fetchData() async {
    setBusy(true);


    try {
      String baseurl = await geturl();

      String date = DateFormat("yyyy-MM-dd").format(selectedDate);
      String name = "$user-$date";

      final url = Uri.parse(
        "$baseurl/api/resource/Employee%20Location/$name",
      );

      final headers = await CompanyAuth.getHeaders();

      final res = await http.get(url, headers: headers);

      final decoded = jsonDecode(res.body);

      final data = decoded["data"];

      final list = data["location_table"] as List;

// distance
      if (list.isNotEmpty) {
        final lastRow = list.last;
        totalDistance =
            double.tryParse(lastRow["distance_km"]?.toString() ?? "0") ?? 0;
      }

// waypoints
      waypoints = list.map<WaypointData>((e) {
        return WaypointData(
          position: LatLng(
            double.tryParse(e["latitude"].toString()) ?? 0,
            double.tryParse(e["longitude"].toString()) ?? 0,
          ),
          referenceType: e["reference_type"]?.toString() ?? "",
          referenceName: e["reference_name"]?.toString() ?? "",
          description: e["description"]?.toString() ?? "",
        );
      }).toList();

      waypoints = waypoints
          .where((w) => w.position.latitude != 0 && w.position.longitude != 0)
          .toList();

// route
      if (waypoints.length >= 2) {
        routePoints = await getRoadRoute(
          waypoints.map((w) => w.position).toList(),
        );
      } else {
        routePoints = waypoints.map((w) => w.position).toList();
      }

// initial position
      if (waypoints.isNotEmpty) {
        initialPosition = waypoints.first.position;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error: $e");
    }

    setBusy(false);
  }

  // ================= MARKERS =================


  //=================================fit map====================================
  LatLngBounds getBounds() {
    final source = routePoints.isNotEmpty
        ? routePoints
        : waypoints.map((w) => w.position).toList();

    final latitudes = source.map((p) => p.latitude);
    final longitudes = source.map((p) => p.longitude);

    return LatLngBounds(
      LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  // ================= route =================
  Future<List<LatLng>> getRoadRoute(List<LatLng> points) async {
    const apiKey = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjYzZmFlMDY1Zjg2ODRjYTY4NDg2M2VjZDZlYTUwODBjIiwiaCI6Im11cm11cjY0In0=";

    final url = Uri.parse(
        "https://api.openrouteservice.org/v2/directions/driving-car");

    final body = jsonEncode({
      "coordinates": points
          .map((p) => [p.longitude, p.latitude])
          .toList(),
    });

    final res = await http.post(
      url,
      headers: {
        "Authorization": apiKey,
        "Content-Type": "application/json",
      },
      body: body,
    );

    final decoded = jsonDecode(res.body);

    final geometry = decoded["routes"][0]["geometry"];

    final decodedPoints =
    PolylinePoints().decodePolyline(geometry);

    return decodedPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
  }
  // ================= DATE PICKER =================
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate = picked;
      await fetchData();
      notifyListeners();
    }
  }

  //=========================== BIKE added===========================
  double getBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (pi / 180);
    final lon1 = start.longitude * (pi / 180);

    final lat2 = end.latitude * (pi / 180);
    final lon2 = end.longitude * (pi / 180);

    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(dLon);

    return atan2(y, x);
  }

  // ================= ANIMATION =================
  Future<void> startAnimation() async {
    // 🛑 stop previous animation if running
    if (isAnimating) {
      stopAnimation = true;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    stopAnimation = false;
    isAnimating = true;

    if (routePoints.length < 2) {
      isAnimating = false;
      return;
    }

    for (int i = 0; i < routePoints.length - 1; i += 4) {
      if (stopAnimation) break;

      final start = routePoints[i];
      final end = routePoints[i + 1];

      final bearing = getBearing(start, end);

      const steps = 4;

      for (int j = 0; j <= steps; j++) {
        if (stopAnimation) break;

        final lat = start.latitude +
            (end.latitude - start.latitude) * (j / steps);

        final lng = start.longitude +
            (end.longitude - start.longitude) * (j / steps);

        final position = LatLng(lat, lng);

        movingMarker = Marker(
          point: position,
          width: 50,
          height: 50,
          child: Transform.rotate(
            angle: bearing,
            child: const Icon(
              Icons.directions_walk,
              color: Colors.black,
              size: 35,
            ),
          ),
        );

        notifyListeners();

        await Future.delayed(
          Duration(milliseconds: (10 / animationSpeed).toInt()),
        );
      }
    }

    isAnimating = false;
  }
}