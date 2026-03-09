import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../router.locator.dart';
import 'company_auth.dart';

class TrackPersonViewModel extends BaseViewModel {
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  // ========================= STATE =========================

  List<String> users = [];
  List<String> filteredUsers = [];
  String selectedUser = "";

  bool showDropdown = false;

  final TextEditingController searchController = TextEditingController();

  final ValueNotifier<List<LatLng>> routePoints = ValueNotifier([]);
  final ValueNotifier<double> distanceKm = ValueNotifier(0);
  final ValueNotifier<_UserInfo> userInfo =
      ValueNotifier(const _UserInfo.empty());

  LatLng? _myLocation;
  LatLng? _lastEmployeeLocation;

  Timer? _pollTimer;
  bool _routeInFlight = false;
  DateTime _lastRouteUpdate =
      DateTime.now().subtract(const Duration(minutes: 5));
  final ValueNotifier<String> destinationAddress = ValueNotifier<String>("");

  LatLng? _lastGeocodedPosition;
  static const Duration _pollInterval = Duration(seconds: 6);
  static const Duration _minRouteGap = Duration(seconds: 40);

  static const String _orsKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjYzZmFlMDY1Zjg2ODRjYTY4NDg2M2VjZDZlYTUwODBjIiwiaCI6Im11cm11cjY0In0=";

  // ========================= INIT =========================
  double _distanceBetween(LatLng a, LatLng b) {
    const earthRadius = 6371000; // meters
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLng = _degToRad(b.longitude - a.longitude);

    final aa = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(a.latitude)) *
            cos(_degToRad(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(aa), sqrt(1 - aa));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * pi / 180;
  Future<void> initialise() async {
    setBusy(true);
    await _determinePosition();
    await fetchUsers();
    setBusy(false);
  }

  // ========================= GPS =========================

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    _myLocation = LatLng(pos.latitude, pos.longitude);
  }

  GoogleMapController? gMapController;

  bool autoFollowEnabled = true;

  Timer? cameraIdleTimer;

  void maybeFollowGoogle() {
    if (!autoFollowEnabled || gMapController == null) return;

    final lat = userInfo.value.lat;
    final lng = userInfo.value.lng;

    if (lat == 0 || lng == 0) return;

    gMapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(lat, lng),
      ),
    );
  }
  // ========================= SEARCH =========================

  void filterUsers(String value) {
    final v = value.trim().toLowerCase();
    filteredUsers = users.where((u) => u.toLowerCase().contains(v)).toList();
    showDropdown = filteredUsers.isNotEmpty;
    notifyListeners();
  }

  void showUserDropdown() {
    if (filteredUsers.isNotEmpty) {
      showDropdown = true;
      notifyListeners();
    }
  }

  void toggleDropdown() {
    showDropdown = !showDropdown;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    filteredUsers = users;
    showDropdown = false;
    notifyListeners();
  }

  void clearSelection() {
    _pollTimer?.cancel();

    routePoints.value = [];
    distanceKm.value = 0;

    selectedUser = "";
    showDropdown = false;

    _lastEmployeeLocation = null;

    searchController.clear();
    userInfo.value = const _UserInfo.empty();

    notifyListeners();
  }

  // ========================= USERS =========================

  Future<void> fetchUsers() async {
    try {
      final url = Uri.parse(
          "https://durocon.erpkey.in/api/resource/Get%20Employee%20Location");

      final headers = await CompanyAuth.getHeaders();
      final res = await http.get(url, headers: headers);

      if (res.statusCode != 200) {
        _showToast("Failed to load users");
        return;
      }

      final decoded = jsonDecode(res.body);
      final list = (decoded["data"] as List?) ?? [];

      users = list
          .map((e) => (e as Map)["name"]?.toString() ?? "")
          .where((e) => e.isNotEmpty)
          .toList();

      filteredUsers = users;
      notifyListeners();
    } catch (_) {
      _showToast("Error loading users");
    }
  }

  // ========================= SELECT USER =========================

  Future<void> selectUser(String user) async {
    selectedUser = user;
    searchController.text = user;
    showDropdown = false;

    routePoints.value = [];
    distanceKm.value = 0;
    userInfo.value = const _UserInfo.empty();

    notifyListeners();

    await _fetchUserLocation();
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchUserLocation());
  }

  // ========================= LOCATION FETCH =========================
  Future<void> _fetchUserLocation() async {
    if (selectedUser.isEmpty) return;

    try {
      final url = Uri.parse(
          "https://durocon.erpkey.in/api/resource/Get%20Employee%20Location/$selectedUser");

      final headers = await CompanyAuth.getHeaders();
      final res = await http.get(url, headers: headers);

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      final data = decoded["data"];

      final lat = (data["latitude"] as num?)?.toDouble() ?? 0;
      final lng = (data["longitude"] as num?)?.toDouble() ?? 0;

      if (lat == 0 || lng == 0) return;

      final currentPosition = LatLng(lat, lng);

      userInfo.value = _UserInfo(
        lat: lat,
        lng: lng,
        battery: (data["battery"] as num?)?.toInt() ?? 0,
      );

      // 🔥 Only reverse geocode if moved > 50 meters
      if (_lastGeocodedPosition == null ||
          _distanceBetween(_lastGeocodedPosition!, currentPosition) > 50) {
        _lastGeocodedPosition = currentPosition;

        final address = await _safeReverseGeocode(lat, lng);

        destinationAddress.value = address;
      }

      await _fetchRoute(currentPosition);
    } catch (e) {
      debugPrint("Fetch location error: $e");
    }
  }

  Future<String> _safeReverseGeocode(
    double lat,
    double lng,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return "Address not found";
      }

      final p = placemarks.first;

      final parts = <String>[
        if ((p.street ?? "").trim().isNotEmpty) p.street!.trim(),
        if ((p.subLocality ?? "").trim().isNotEmpty) p.subLocality!.trim(),
        if ((p.locality ?? "").trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? "").trim().isNotEmpty)
          p.administrativeArea!.trim(),
        if ((p.country ?? "").trim().isNotEmpty) p.country!.trim(),
      ];

      return parts.isEmpty ? "Address not found" : parts.join(", ");
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
      return "Address not found";
    }
  }

  // ========================= ROUTE =========================

  Future<void> _fetchRoute(LatLng destination) async {
    if (_routeInFlight) return;
    if (_myLocation == null) return;

    if (DateTime.now().difference(_lastRouteUpdate) < _minRouteGap) return;

    _routeInFlight = true;

    try {
      final url = Uri.parse(
          "https://api.openrouteservice.org/v2/directions/driving-car");

      final body = jsonEncode({
        "coordinates": [
          [_myLocation!.longitude, _myLocation!.latitude],
          [destination.longitude, destination.latitude],
        ],
      });

      final res = await http
          .post(
            url,
            headers: {
              "Authorization": _orsKey,
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: body,
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      final routes = decoded["routes"];
      if (routes == null || routes.isEmpty) return;

      _lastRouteUpdate = DateTime.now();

      final summary = routes[0]["summary"];
      final distM = (summary["distance"] as num?)?.toDouble() ?? 0;

      distanceKm.value = distM / 1000;

      final geometry = routes[0]["geometry"];
      final decodedPts = PolylinePoints().decodePolyline(geometry);

      routePoints.value =
          decodedPts.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } finally {
      _routeInFlight = false;
    }
  }

  // ========================= UTIL =========================

  @override
  void dispose() {
    _pollTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}

// ========================= MODEL =========================

class _UserInfo {
  final double lat;
  final double lng;
  final int battery;

  const _UserInfo({
    required this.lat,
    required this.lng,
    required this.battery,
  });

  const _UserInfo.empty()
      : lat = 0,
        lng = 0,
        battery = 0;
}
