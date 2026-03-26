import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'company_auth.dart';
import '../../../constants.dart';

// ── DATA MODEL ─────────────────────────────────────────────

class WaypointData {
  final LatLng position;
  final String referenceType;
  final String referenceName;
  final String description;
  final String datetime;

  WaypointData({
    required this.position,
    required this.referenceType,
    required this.referenceName,
    required this.description,
    required this.datetime,
  });
}

// ── VIEWMODEL ─────────────────────────────────────────────

class WaypointViewModel extends BaseViewModel {
  final String user;

  WaypointViewModel(this.user);

  GoogleMapController? googleMapController;

  List<WaypointData> waypoints = [];
  List<LatLng> routePoints = [];

  LatLng? movingMarkerPosition;

  double totalDistance = 0;
  BitmapDescriptor? walkIcon;
  bool isAnimating = false;
  bool stopAnimation = false;
  bool isMapReady = false;

  DateTime selectedDate = DateTime.now();

  LatLng initialPosition = const LatLng(16.8512, 74.6126);

  double animationSpeed = 3.0;
  List<BitmapDescriptor> markerIcons = [];
  // ── INIT ─────────────────────────────────────────────

  Future<void> init() async {
    await loadWalkIcon();
    await fetchData();

  }

  // ── FETCH DATA ───────────────────────────────────────

  Future<void> fetchData() async {
    setBusy(true);

    try {
      final baseurl = await geturl();
      final date = DateFormat("yyyy-MM-dd").format(selectedDate);
      final name = "$user-$date";

      final url = Uri.parse(
        "$baseurl/api/resource/Employee%20Location/$name",
      );

      final headers = await CompanyAuth.getHeaders();

      final startTime = DateTime.now();

      final res = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 20));

      debugPrint(
          "API Time: ${DateTime.now().difference(startTime).inSeconds}s");

      final decoded = jsonDecode(res.body);
      final data = decoded["data"];
      final list = data["location_table"] as List;

      if (list.isNotEmpty) {
        final lastRow = list.last;
        totalDistance =
            double.tryParse(lastRow["Distance(in Km)"]?.toString() ?? "0") ?? 0;
      }

      waypoints = list.map<WaypointData>((e) {
        return WaypointData(
          position: LatLng(
            double.tryParse(e["latitude"].toString()) ?? 0,
            double.tryParse(e["longitude"].toString()) ?? 0,
          ),
          referenceType: e["reference_type"]?.toString() ?? "",
          referenceName: e["reference_name"]?.toString() ?? "",
          description: e["description"]?.toString() ?? "",
          datetime: e["datetime"]?.toString() ?? "",
        );
      }).where((w) =>
      w.position.latitude != 0 && w.position.longitude != 0).toList();

      debugPrint("Waypoints count: ${waypoints.length}");

      if (waypoints.length >= 2) {
        routePoints = await buildRouteInChunks(
          waypoints.map((w) => w.position).toList(),
        );
      } else {
        routePoints = waypoints.map((w) => w.position).toList();
      }

      if (waypoints.isNotEmpty) {
        initialPosition = waypoints.first.position;
      }

      notifyListeners();
      await generateMarkerIcons();
    } catch (e) {
      debugPrint("fetchData error: $e");
    }

    setBusy(false);
  }

  // ----------------- icon

  Future<void> loadWalkIcon() async {
    try {
      final data = await rootBundle.load('assets/images/walking.png');
      final bytes = data.buffer.asUint8List();

      final codec = await instantiateImageCodec(bytes, targetWidth: 80);
      final frame = await codec.getNextFrame();

      final resizedBytes = await frame.image.toByteData(format: ImageByteFormat.png);

      walkIcon = BitmapDescriptor.fromBytes(resizedBytes!.buffer.asUint8List());

      debugPrint("✅ Large icon loaded");
    } catch (e) {
      debugPrint("❌ Icon error: $e");
    }
  }


  // ── CHUNKED ROUTE BUILDER ─────────────────────────────

  Future<List<LatLng>> buildRouteInChunks(List<LatLng> points) async {
    List<LatLng> fullRoute = [];

    for (int i = 0; i < points.length - 1; i++) {
      final segment = [points[i], points[i + 1]];

      final part = await getRoadRoute(segment);
      fullRoute.addAll(part);

      await Future.delayed(const Duration(milliseconds: 100));
    }

    return fullRoute;
  }

  // ── ROAD ROUTE ───────────────────────────────────────

  Future<List<LatLng>> getRoadRoute(List<LatLng> points) async {
    const apiKey =
        "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjYzZmFlMDY1Zjg2ODRjYTY4NDg2M2VjZDZlYTUwODBjIiwiaCI6Im11cm11cjY0In0=";

    final url = Uri.parse(
        "https://api.openrouteservice.org/v2/directions/driving-car");

    try {
      final res = await http
          .post(
        url,
        headers: {
          "Authorization": apiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "coordinates": points
              .map((p) => [p.longitude, p.latitude])
              .toList(),
        }),
      )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(res.body);

      if (decoded["routes"] == null || decoded["routes"].isEmpty) {
        debugPrint("Route API failed: ${res.body}");
        return [];
      }

      final geometry = decoded["routes"][0]["geometry"];
      final decodedPoints =
      PolylinePoints().decodePolyline(geometry);

      return decodedPoints
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    } catch (e) {
      debugPrint("Route error: $e");
      return [];
    }
  }

  // ── DATE PICKER ───────────────────────────────────────

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate = picked;

      stopAnimation = true;
      movingMarkerPosition = null;

      await fetchData();

      if (googleMapController != null &&
          (routePoints.isNotEmpty || waypoints.isNotEmpty)) {
        final bounds = getBounds();

        googleMapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 80),
        );
      }

      notifyListeners();
    }
  }

  // ── ANIMATION ───────────────────────────────────────

  Future<void> startAnimation() async {
    if (isAnimating) {
      stopAnimation = true;
      await Future.delayed(const Duration(milliseconds: 150));
    }

    stopAnimation = false;
    isAnimating = true;
    movingMarkerPosition = null;

    if (routePoints.length < 2) {
      isAnimating = false;
      return;
    }

    for (int i = 0; i < routePoints.length - 1; i += 3) {
      if (stopAnimation) break;

      final start = routePoints[i];
      final end = routePoints[i + 1];

      const steps = 4;

      for (int j = 0; j <= steps; j++) {
        if (stopAnimation) break;

        final lat =
            start.latitude + (end.latitude - start.latitude) * (j / steps);
        final lng =
            start.longitude + (end.longitude - start.longitude) * (j / steps);

        movingMarkerPosition = LatLng(lat, lng);



        notifyListeners();

        await Future.delayed(
          Duration(milliseconds: max(16, (30 / animationSpeed).toInt())),
        );
      }
    }

    isAnimating = false;
    notifyListeners();
  }

  String get selectedDateLabel {
    final now = DateTime.now();

    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return "Today";
    }

    return DateFormat("dd MMM").format(selectedDate);
  }
  // ── STOP ANIMATION ───────────────────────────────────

  void cancelAnimation() {
    stopAnimation = true;
    isAnimating = false;
    movingMarkerPosition = null;
    notifyListeners();
  }

  //===================== custom marker
  Future<BitmapDescriptor> createNumberedMarker(int number, Color color) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    const double size = 80; // 🔥 smaller size
    final center = Offset(size / 2, size / 2);

    // circle
    final paint = Paint()..color = color;
    canvas.drawCircle(center, 28, paint); // 🔥 smaller radius

    // text
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          fontSize: 24, // 🔥 reduced
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final img = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }
  //--------------------- marker

  Future<void> generateMarkerIcons() async {
    markerIcons.clear();

    for (int i = 0; i < waypoints.length; i++) {
      final color = i == 0
          ? Colors.green
          : i == waypoints.length - 1
          ? Colors.red
          : Colors.blue;

      final icon = await createNumberedMarker(i + 1, color);

      markerIcons.add(icon);
    }

    notifyListeners();
  }

  // ── BOUNDS ───────────────────────────────────────────

  LatLngBounds getBounds() {
    final source = routePoints.isNotEmpty
        ? routePoints
        : waypoints.map((w) => w.position).toList();

    final latitudes = source.map((p) => p.latitude);
    final longitudes = source.map((p) => p.longitude);

    return LatLngBounds(
      southwest: LatLng(
        latitudes.reduce(min),
        longitudes.reduce(min),
      ),
      northeast: LatLng(
        latitudes.reduce(max),
        longitudes.reduce(max),
      ),
    );
  }
}