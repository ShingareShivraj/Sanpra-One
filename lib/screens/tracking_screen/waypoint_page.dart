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
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
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
        model.init();

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Show no data dialog if needed
          if (model.hasNoData) {
            _showNoDataDialog(context, model);
            return;
          }

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

        // ── Listen for hasNoData changes after date picks
        model.addListener(() {
          if (!context.mounted) return;

          if (model.hasNoData && !model.isBusy) {
            _showNoDataDialog(context, model);
          } else if (!model.hasNoData && !model.isBusy && _isNoDataDialogOpen) {
            _isNoDataDialogOpen = false;
            Navigator.of(context, rootNavigator: true).pop();
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
// ── LOADER ───────────────────────────────────────────────

  Widget _buildLoader() {
    return const TravelLoader();
  }

  Widget _buildGoogleMap(WaypointViewModel model) {
    final Set<Polyline> polylines = {};

    if (model.travelledPoints.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId("travelled"),
        points: model.travelledPoints,
        width: 5,
        color: const Color(0xFF4F46E5),
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }

    if (model.remainingPoints.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId("remaining"),
        points: model.remainingPoints,
        width: 3,
        color: const Color(0xFFD1D5DB),
        patterns: [PatternItem.dash(12), PatternItem.gap(8)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }

    if (model.travelledPoints.isEmpty &&
        model.remainingPoints.isEmpty &&
        model.routePoints.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId("route"),
        points: model.routePoints,
        width: 5,
        color: const Color(0xFF4F46E5),
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ));
    }

    // Static waypoint markers — built once, not on every tick
    final Set<Marker> staticMarkers = {
      for (int i = 0; i < model.waypoints.length; i++)
        Marker(
          markerId: MarkerId("wp_$i"),
          position: model.waypoints[i].position,
          icon: model.markerIcons.length > i
              ? model.markerIcons[i]
              : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: model.waypoints[i].referenceName.isNotEmpty
                ? model.waypoints[i].referenceName
                : "Stop ${i + 1}",
            snippet: model.waypoints[i].referenceType,
          ),
          onTap: () => _showWaypointSheet(context, model.waypoints[i], i),
        ),
    };

    return ValueListenableBuilder<LatLng?>(
      valueListenable: model.movingMarkerNotifier,
      builder: (context, movingPos, child) {
        // Only this builder reruns on every tick — GoogleMap is in child
        final Set<Marker> allMarkers = {
          ...staticMarkers,
          if (movingPos != null)
            Marker(
              markerId: const MarkerId("moving"),
              position: movingPos,
              icon: model.walkIcon ?? BitmapDescriptor.defaultMarker,
              zIndex: 10,
            ),
        };

        // Swap markers on the existing GoogleMap via a stateful marker layer
        return _MarkerOverlayMap(
          googleMap: child! as GoogleMap,
          markers: allMarkers,
        );
      },
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: model.initialPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          model.googleMapController = controller;
          if (model.routePoints.isNotEmpty || model.waypoints.isNotEmpty) {
            final bounds = model.getBounds();
            Future.delayed(const Duration(milliseconds: 300), () {
              controller.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 80),
              );
            });
          }
        },
        markers: staticMarkers,
        polylines: polylines,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        padding: const EdgeInsets.only(bottom: 220),
      ),
    );
  }

  Widget _buildTopOverlay(WaypointViewModel model) {
    // Progress % along route
    final progress = model.routePoints.isEmpty
        ? 0.0
        : (model.travelledPoints.length / model.routePoints.length)
            .clamp(0.0, 1.0);
    final progressPct = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top row: chips + recenter
        Row(
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
            const SizedBox(width: 8),
            // Only show % chip when animating
            if (model.isAnimating)
              _OverlayChip(
                icon: Icons.moving_rounded,
                label: "$progressPct% done",
                iconColor: Colors.white,
                bgColor: Colors.blue,
              ),
            const Spacer(),
            // Recenter button
            GestureDetector(
              onTap: () {
                if (model.isAnimating && model.movingMarkerPosition != null) {
                  // Follow marker when animating
                  model.googleMapController?.animateCamera(
                    CameraUpdate.newLatLng(model.movingMarkerPosition!),
                  );
                } else if (model.routePoints.isNotEmpty ||
                    model.waypoints.isNotEmpty) {
                  // Fit full route when idle
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
                child: Icon(
                  model.isAnimating
                      ? Icons.my_location_rounded // follow icon when animating
                      : Icons.fit_screen_rounded, // fit icon when idle
                  size: 17,
                  color: model.isAnimating
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),

        // ── Progress bar (only when animating)
        if (model.isAnimating) ...[
          const SizedBox(height: 10),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                ),
              ],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _isNoDataDialogOpen = false;
  void _showNoDataDialog(BuildContext context, WaypointViewModel model) {
    if (_isNoDataDialogOpen) return;
    _isNoDataDialogOpen = true;

    final dateLabel = DateFormat("EEEE, d MMM yyyy").format(model.selectedDate);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(44),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.map_outlined,
                        size: 44, color: Color(0xFF4F46E5)),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.close,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'No trips found',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
                  children: [
                    const TextSpan(text: 'No travel history recorded for\n'),
                    TextSpan(
                      text: dateLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 14, color: Color(0xFFF59E0B)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Try selecting a different date from the calendar.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _isNoDataDialogOpen = false;
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Go back',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _isNoDataDialogOpen = false;
                        Navigator.pop(ctx);
                        model.pickDate(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Pick date',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // Safety net — always reset flag when dialog closes for any reason
      _isNoDataDialogOpen = false;
    });
  }
  // ── BOTTOM PANEL ──────────────────────────────────────────
  Widget _buildBottomPanel(BuildContext context, WaypointViewModel model) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              // Stop count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${model.waypoints.length} stops",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    "${model.totalDistance.toStringAsFixed(1)} km total",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Start / Stop button
              GestureDetector(
                onTap: () {
                  if (!model.isAnimating) {
                    model.startAnimation();
                  } else {
                    model.cancelAnimation();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: model.isAnimating
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (model.isAnimating
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF4F46E5))
                            .withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          model.isAnimating
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey(model.isAnimating),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          model.isAnimating ? 'Stop' : 'Start',
                          key: ValueKey(model.isAnimating),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Speed slider
          Row(
            children: [
              const Icon(Icons.slow_motion_video_rounded,
                  size: 15, color: Color(0xFF9CA3AF)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: const Color(0xFF4F46E5),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: const Color(0xFF4F46E5),
                    overlayColor: const Color(0xFF4F46E5).withOpacity(0.12),
                  ),
                  child: Slider(
                    value: model.animationSpeed,
                    min: 0.5,
                    max: 4.0,
                    divisions: 7,
                    onChanged: (v) {
                      model.animationSpeed = v;
                      model.notifyListeners();
                    },
                  ),
                ),
              ),
              const Icon(Icons.fast_forward_rounded,
                  size: 15, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(
                "${model.animationSpeed.toStringAsFixed(1)}×",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
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

// ── TRAVEL LOADER ─────────────────────────────────────────
class TravelLoader extends StatefulWidget {
  const TravelLoader({super.key});

  @override
  State<TravelLoader> createState() => _TravelLoaderState();
}

class _TravelLoaderState extends State<TravelLoader>
    with TickerProviderStateMixin {
  // ── Plane animation
  late AnimationController _planeController;
  late Animation<double> _planeAnimation;
  late Animation<double> _planeFade;

  // ── Text fade animation
  late AnimationController _textFadeController;
  late Animation<double> _textFade;

  // ── Steps + facts
  final List<String> _steps = [
    '🏍️  Tracing today\'s bike route...',
    '📍  Mapping visited dealers...',
    '📏  Calculating kilometres covered...',
    '🕐  Logging check-in timestamps...',
  ];

  final List<String> _facts = [
    '🏍️  Maharashtra has over 2.5 lakh km of roads to ride!',
    '🌄  Pune to Nashik — a classic sales corridor at ~210 km.',
    '☀️  Peak sales visits in Maharashtra: Oct – Feb season.',
    '🛣️  Mumbai–Nagpur Samruddhi Expressway cuts travel time by half.',
    '🏪  Maharashtra has one of India\'s largest dealer networks.',
    '⛽  Avg bike sales rep covers 80–120 km per day on field.',
    '🌧️  Monsoon tip: Konkan routes get slippery — ride safe!',
    '📦  Aurangabad & Pune are key FMCG distribution hubs.',
  ];

  int _currentIndex = 0;
  bool _showingFact = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();

    // Plane loop
    _planeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _planeAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _planeController, curve: Curves.easeInOut),
    );

    _planeFade = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_planeController);

    // Text fade
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _textFade = CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeInOut,
    );

    _currentText = _steps[0];
    _textFadeController.forward();
    _startCycle();
  }

  Future<void> _startCycle() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;

      await _textFadeController.reverse();
      if (!mounted) return;

      setState(() {
        _currentIndex = i;
        _currentText = i < _steps.length - 1 ? _steps[i + 1] : _getFact();
        _showingFact = i == _steps.length - 1;
      });

      await _textFadeController.forward();
    }

    // Keep cycling facts
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 2800));
      if (!mounted) return;

      await _textFadeController.reverse();
      if (!mounted) return;

      setState(() => _currentText = _getFact());

      await _textFadeController.forward();
    }
  }

  final List<int> _usedFactIndices = [];

  String _getFact() {
    if (_usedFactIndices.length == _facts.length) {
      _usedFactIndices.clear();
    }
    final available = List.generate(_facts.length, (i) => i)
        .where((i) => !_usedFactIndices.contains(i))
        .toList();
    final pick =
        available[DateTime.now().millisecondsSinceEpoch % available.length];
    _usedFactIndices.add(pick);
    return _facts[pick];
  }

  @override
  void dispose() {
    _planeController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Bike icon + trail
            SizedBox(
              width: 220,
              height: 60,
              child: AnimatedBuilder(
                animation: _planeController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 60),
                        painter: _DashedLinePainter(
                          color: const Color(0xFF4F46E5).withOpacity(0.25),
                          progress: _planeAnimation.value,
                        ),
                      ),
                      Positioned(
                        left: _planeAnimation.value * 220 - 16,
                        top: 14,
                        child: Opacity(
                          opacity: _planeFade.value,
                          // 🏍️ Bike icon instead of plane
                          child: const Icon(
                            Icons.two_wheeler,
                            color: Color(0xFF4F46E5),
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // ── "Maharashtra Field Tour" label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🗺️  Maharashtra Field Tour',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F46E5),
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Step indicator dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_steps.length, (i) {
                final isActive = !_showingFact && i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF4F46E5).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── Fading text
            FadeTransition(
              opacity: _textFade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _currentText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _showingFact
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF6B7280),
                    fontSize: _showingFact ? 12.5 : 13,
                    fontWeight:
                        _showingFact ? FontWeight.w500 : FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double progress;

  _DashedLinePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 5.0;
    final endX = progress * size.width;
    double x = 0;
    final y = size.height / 2;

    while (x < endX) {
      final end = (x + dashWidth).clamp(0.0, endX);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) =>
      old.progress != progress || old.color != color;
}

// Rebuilds only markers, not the full GoogleMap
class _MarkerOverlayMap extends StatefulWidget {
  final GoogleMap googleMap;
  final Set<Marker> markers;

  const _MarkerOverlayMap({
    required this.googleMap,
    required this.markers,
  });

  @override
  State<_MarkerOverlayMap> createState() => _MarkerOverlayMapState();
}

class _MarkerOverlayMapState extends State<_MarkerOverlayMap> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: widget.googleMap.mapType,
      initialCameraPosition: widget.googleMap.initialCameraPosition,
      onMapCreated: (controller) {
        _controller = controller;
        widget.googleMap.onMapCreated?.call(controller);
      },
      markers: widget.markers,          // ← updates every tick
      polylines: widget.googleMap.polylines ?? {},  // ← stable, no rebuild
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      padding: widget.googleMap.padding,
    );
  }
}