import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'waypoint_viewmodel.dart';

class WaypointPage extends StatefulWidget {
  final String user;

  const WaypointPage({super.key, required this.user});

  @override
  State<WaypointPage> createState() => _WaypointPageState();
}

class _WaypointPageState extends State<WaypointPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WaypointViewModel>.reactive(
      viewModelBuilder: () => WaypointViewModel(widget.user),
      onViewModelReady: (model) {
        // Initialize only once
        model.init();

        // Ensure map is ready after first frame
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          model.isMapReady = true;

          await Future.delayed(const Duration(milliseconds: 400));
          if (model.googleMapController != null &&
              (model.routePoints.isNotEmpty || model.waypoints.isNotEmpty)) {
            final bounds = model.getBounds();
            model.googleMapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          }
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: _buildAppBar(context, model),
          body: model.isBusy
              ? _buildLoader()
              : FadeTransition(
            opacity: _fadeAnim,
            child: Stack(
              children: [
                _buildGoogleMap(model),
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: _buildTopOverlay(model),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomPanel(context, model),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WaypointViewModel model) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: const Color(0xFFE5E7EB)),
      ),
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: Color(0xFF374151)),
          ),
        ),
      ),
      titleSpacing: 4,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Travel History",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          Text(
            widget.user,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: () => model.pickDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 13, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                Text(
                  model.selectedDateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── LOADER ───────────────────────────────────────────────

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFF4F46E5),
      ),
    );
  }

  // ── GOOGLE MAP ───────────────────────────────────────────

  Widget _buildGoogleMap(WaypointViewModel model) {
    final Set<Marker> markers = {};

    for (int i = 0; i < model.waypoints.length; i++) {
      final wp = model.waypoints[i];
      final isFirst = i == 0;
      final isLast = i == model.waypoints.length - 1;

      final BitmapDescriptor icon = isFirst
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
          : isLast
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
          : BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure);

      markers.add(Marker(
        markerId: MarkerId("wp_$i"),
        position: wp.position,
        icon: model.markerIcons.length > i
            ? model.markerIcons[i]
            : BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: wp.referenceName.isNotEmpty ? wp.referenceName : "Stop ${i + 1}",
          snippet: wp.referenceType,
        ),
        onTap: () => _showWaypointSheet(context, wp, i),
      ));
    }

    if (model.movingMarkerPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId("moving"),
        position: model.movingMarkerPosition!,
        icon: model.walkIcon ?? BitmapDescriptor.defaultMarker,
        zIndex: 10,
      ));
    }

    final Set<Polyline> polylines = {};
    if (model.routePoints.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId("route"),
        points: model.routePoints,
        width: 5,
        color: const Color(0xFF4F46E5),
      ));
    }

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: model.initialPosition,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        model.googleMapController = controller;

        // Animate to bounds after map is ready
        if (model.routePoints.isNotEmpty || model.waypoints.isNotEmpty) {
          final bounds = model.getBounds();
          Future.delayed(const Duration(milliseconds: 300), () {
            controller.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          });
        }
      },
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(bottom: 200),
    );
  }

  // ── TOP OVERLAY ───────────────────────────────────────────

  Widget _buildTopOverlay(WaypointViewModel model) {
    return Row(
      children: [
        _OverlayChip(
          icon: Icons.route_outlined,
          label: "${model.totalDistance.toStringAsFixed(2)} km",
          iconColor: const Color(0xFF4F46E5),
          bgColor: Colors.white,
        ),
        const SizedBox(width: 8),
        _OverlayChip(
          icon: Icons.location_on_rounded,
          label: "${model.waypoints.length} stops",
          iconColor: const Color(0xFF059669),
          bgColor: Colors.white,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            if (model.routePoints.isNotEmpty || model.waypoints.isNotEmpty) {
              final bounds = model.getBounds();
              model.googleMapController?.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 80),
              );
            }
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.fit_screen_rounded,
                size: 17, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  // ── BOTTOM PANEL ──────────────────────────────────────────
  Widget _buildBottomPanel(BuildContext context, WaypointViewModel model) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(
            "${model.waypoints.length} stops",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          ElevatedButton.icon(
            onPressed: model.startAnimation,
            icon: const Icon(Icons.play_arrow),
            label: const Text("Start"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showWaypointSheet(BuildContext context, dynamic wp, int index) {}
}

// ── REUSABLE CHIP ──────────────────────────────────────────

class _OverlayChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const _OverlayChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}