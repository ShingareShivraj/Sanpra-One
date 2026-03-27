import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import '../../services/waypoint_services.dart';

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
enum _MarkerType { start, end, middle }

// ── VIEWMODEL ─────────────────────────────────────────────

class WaypointViewModel extends BaseViewModel {
  final String user;

  WaypointViewModel(this.user);

  final WaypointServices _service = WaypointServices();

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
  bool hasNoData = false;
  // ── INIT ─────────────────────────────────────────────

  Future<void> init() async {
    await loadWalkIcon();
    await fetchData();
  }

  // ── FETCH DATA ─────────────────────────────────────────

  Future<void> fetchData() async {
    setBusy(true);
    hasNoData = false;

    try {
      final date = DateFormat("yyyy-MM-dd").format(selectedDate);

      final response = await _service.fetchEmployeeLocations(
        user: user,
        date: date,
      );

      Logger().i(response?.toJson());

      if (response == null || response.locationTable == null
          || response.locationTable!.isEmpty) {
        waypoints = [];
        routePoints = [];
        hasNoData = true;          // ← signal the view
        setBusy(false);
        notifyListeners();
        return;
      }

      final locationList = response.locationTable!;

      waypoints = locationList
          .map<WaypointData>((e) {
        final lat = double.tryParse(e.latitude ?? "0") ?? 0;
        final lng = double.tryParse(e.longitude ?? "0") ?? 0;
        return WaypointData(
          position: LatLng(lat, lng),
          referenceType: e.referenceType ?? "",
          referenceName: e.referenceName ?? "",
          description: e.address ?? "",
          datetime: e.datetime ?? "",
        );
      })
          .where((w) => w.position.latitude != 0 && w.position.longitude != 0)
          .toList();

      totalDistance = response.distance ?? 0;

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

  String get selectedDateLabel {
    final now = DateTime.now();
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      return "Today";
    }
    return DateFormat("dd MMM").format(selectedDate);
  }

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

  // ── ROUTE ─────────────────────────────────────────────

  Future<List<LatLng>> getRoadRoute(List<LatLng> points) async {
    try {
      final routes = await _service.getRoute(
        points.map((p) => [p.longitude, p.latitude]).toList(),
      );

      if (routes.isEmpty) return [];

      final geometry = routes[0]["geometry"];

      final decodedPoints = PolylinePoints().decodePolyline(geometry);

      return decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } catch (e) {
      debugPrint("Route error: $e");
      return [];
    }
  }

  Future<List<LatLng>> buildRouteInChunks(List<LatLng> points) async {
    List<LatLng> fullRoute = [];

    for (int i = 0; i < points.length - 1; i++) {
      final part = await getRoadRoute([points[i], points[i + 1]]);
      fullRoute.addAll(part);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return fullRoute;
  }

  // ── ICON ─────────────────────────────────────────────

  Future<void> loadWalkIcon() async {
    try {
      final data = await rootBundle.load('assets/images/walking.png');
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 80);
      final frame = await codec.getNextFrame();
      final resizedBytes =
      await frame.image.toByteData(format: ui.ImageByteFormat.png);
      walkIcon = BitmapDescriptor.bytes(resizedBytes!.buffer.asUint8List());
    } catch (e) {
      debugPrint("Icon error: $e");
    }
  }

// ── MARKER TYPES ─────────────────────────────────────────


// ── MAIN FACTORY ─────────────────────────────────────────

  Future<BitmapDescriptor> createNumberedMarker(
  int number,
  Color color, {
  _MarkerType type = _MarkerType.middle,
  }) async {
  const double canvasSize = 120.0;
  const double pinWidth = 72.0;
  const double headRadius = 28.0;
  const double tailHeight = 22.0;
  const double centerX = canvasSize / 2;
  const double headCenterY = headRadius + 14; // top padding for shadow

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
  recorder,
  Rect.fromLTWH(0, 0, canvasSize, canvasSize),
  );

  // ── 1. Shadow
  final shadowPaint = Paint()
  ..color = Colors.black.withOpacity(0.18)
  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  canvas.drawOval(
  Rect.fromCenter(
  center: Offset(centerX, headCenterY + headRadius + tailHeight - 2),
  width: 28,
  height: 8,
  ),
  shadowPaint,
  );

  // ── 2. Pin path (teardrop)
  final pinPath = _buildPinPath(
  centerX: centerX,
  headCenterY: headCenterY,
  headRadius: headRadius,
  tailHeight: tailHeight,
  );

  // Outer ring (border)
  final borderPaint = Paint()
  ..color = color
  ..style = PaintingStyle.fill;
  // Scale up slightly for border
  final borderPath = _buildPinPath(
  centerX: centerX,
  headCenterY: headCenterY,
  headRadius: headRadius + 4,
  tailHeight: tailHeight + 2,
  );
  canvas.drawPath(borderPath, borderPaint);

  // White fill
  final fillPaint = Paint()
  ..color = Colors.white
  ..style = PaintingStyle.fill;
  canvas.drawPath(pinPath, fillPaint);

  // ── 3. Icon or number inside head
  switch (type) {
  case _MarkerType.start:
  _drawIcon(canvas, centerX, headCenterY, color, Icons.play_arrow_rounded);
  break;
  case _MarkerType.end:
  _drawIcon(canvas, centerX, headCenterY, color, Icons.flag_rounded);
  break;
  case _MarkerType.middle:
  _drawNumber(canvas, centerX, headCenterY, number, color);
  break;
  }

  final img = await recorder
      .endRecording()
      .toImage(canvasSize.toInt(), canvasSize.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

// ── PIN PATH ─────────────────────────────────────────────

  Path _buildPinPath({
  required double centerX,
  required double headCenterY,
  required double headRadius,
  required double tailHeight,
  }) {
  final path = Path();
  // Circle head
  path.addOval(Rect.fromCircle(
  center: Offset(centerX, headCenterY),
  radius: headRadius,
  ));
  // Triangle tail
  final tailTop = headCenterY + headRadius * 0.7;
  final tailTip = headCenterY + headRadius + tailHeight;
  path.moveTo(centerX - headRadius * 0.45, tailTop);
  path.quadraticBezierTo(centerX, tailTip + 4, centerX, tailTip);
  path.quadraticBezierTo(centerX, tailTip + 4, centerX + headRadius * 0.45, tailTop);
  path.close();
  return path;
  }

// ── DRAW NUMBER ───────────────────────────────────────────

  void _drawNumber(
  Canvas canvas,
  double cx,
  double cy,
  int number,
  Color color,
  ) {
  final textPainter = TextPainter(
  text: TextSpan(
  text: number.toString(),
  style: TextStyle(
  fontSize: number > 9 ? 20 : 24,
  color: color,
  fontWeight: FontWeight.bold,
  ),
  ),
  textDirection: ui.TextDirection.ltr,
  )..layout();

  textPainter.paint(
  canvas,
  Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
  );
  }

// ── DRAW ICON (start / end) ───────────────────────────────

  void _drawIcon(
  Canvas canvas,
  double cx,
  double cy,
  Color color,
  IconData iconData,
  ) {
  final textPainter = TextPainter(
  text: TextSpan(
  text: String.fromCharCode(iconData.codePoint),
  style: TextStyle(
  fontSize: 26,
  color: color,
  fontFamily: iconData.fontFamily,
  package: iconData.fontPackage,
  ),
  ),
  textDirection: ui.TextDirection.ltr,
  )..layout();

  textPainter.paint(
  canvas,
  Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
  );
  }

// ── GENERATE ALL MARKERS ──────────────────────────────────

  Future<void> generateMarkerIcons() async {
  markerIcons.clear();

  for (int i = 0; i < waypoints.length; i++) {
  final isStart = i == 0;
  final isEnd = i == waypoints.length - 1;

  final color = isStart
  ? const Color(0xFF059669)  // green for start
      : isEnd
  ? const Color(0xFFEF4444)   // red for end
      : const Color(0xFF4F46E5);  // indigo for middle

  final type = isStart
  ? _MarkerType.start
      : isEnd
  ? _MarkerType.end
      : _MarkerType.middle;

  final icon = await createNumberedMarker(i + 1, color, type: type);
  markerIcons.add(icon);
  }

  notifyListeners();
  }
  // ── ANIMATION ─────────────────────────────────────────────

  // Add to ViewModel
  List<LatLng> travelledPoints = [];
  List<LatLng> remainingPoints = [];
  int _cameraFollowCounter = 0;
// Add in your WaypointViewModel class — alongside your other fields
  final ValueNotifier<LatLng?> movingMarkerNotifier = ValueNotifier(null);
  Future<void> startAnimation() async {
    if (isAnimating) {
      stopAnimation = true;
      await Future.delayed(const Duration(milliseconds: 150));
    }

    stopAnimation = false;
    isAnimating = true;
    travelledPoints = [];
    remainingPoints = List.from(routePoints);
    movingMarkerPosition = null;
    movingMarkerNotifier.value = null;
    _cameraFollowCounter = 0;
    notifyListeners();

    if (routePoints.length < 2) {
      isAnimating = false;
      notifyListeners();
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

        // ── Only notify marker — no full rebuild
        movingMarkerNotifier.value = LatLng(lat, lng);

        // ── Update polyline split only at end of each segment
        if (j == steps) {
          travelledPoints = routePoints.sublist(0, i + 1);
          remainingPoints =
              (i + 1 < routePoints.length) ? routePoints.sublist(i + 1) : [];
          notifyListeners(); // full rebuild only when polyline changes
        }

        // ── Camera follow every 8 ticks — smooth but not every frame
        _cameraFollowCounter++;
        if (_cameraFollowCounter % 8 == 0) {
          googleMapController?.moveCamera(
            CameraUpdate.newLatLng(movingMarkerPosition!),
          );
        }

        await Future.delayed(
          Duration(milliseconds: max(16, (30 / animationSpeed).toInt())),
        );
      }
    }

    // Done
    travelledPoints = List.from(routePoints);
    remainingPoints = [];
    isAnimating = false;
    movingMarkerPosition = null;
    movingMarkerNotifier.value = null;
    notifyListeners();
  }

// In cancelAnimation:
  void cancelAnimation() {
    stopAnimation = true;
    isAnimating = false;
    movingMarkerPosition = null;
    movingMarkerNotifier.value = null;
    travelledPoints = [];
    remainingPoints = [];
    notifyListeners();
  }

  @override
  void dispose() {
    movingMarkerNotifier.dispose();
    super.dispose();
  }
  // ── DATE PICKER ─────────────────────────────────────────

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
}
