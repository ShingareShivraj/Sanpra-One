import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

import 'track_page_viewmodel.dart';
import 'waypoint_page.dart';

class TrackPersonPage extends StatefulWidget {
  const TrackPersonPage({super.key});

  @override
  State<TrackPersonPage> createState() => _TrackPersonPageState();
}

class _TrackPersonPageState extends State<TrackPersonPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: false);

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<TrackPersonViewModel>.reactive(
      viewModelBuilder: () => TrackPersonViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: _buildAppBar(theme, model),
          body: fullScreenLoader(
            context: context,
            loader: model.isBusy,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _buildSearch(theme, model),
                  const SizedBox(height: 12),
                  if (model.showDropdown) _buildDropdown(theme, model),
                  if (model.selectedUser.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildMapCard(context, theme, model),
                    const SizedBox(height: 14),
                    _buildInfoCard(context, theme, model),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      ThemeData theme, TrackPersonViewModel model) {
    return AppBar(
      // backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: const Color(0xFFE5E7EB),
        ),
      ),
      titleSpacing: 16,
      title: const Text(
        "Track Person",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          // color: Color(0xFF111827),
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        _AppBarIconButton(
          tooltip: "Refresh",
          icon: Icons.refresh_rounded,
          onTap: model.fetchUsers,
        ),
        _AppBarIconButton(
          tooltip: "Clear",
          icon: Icons.close_rounded,
          onTap: model.clearSelection,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── SEARCH ───────────────────────────────────────────────────────────────

  Widget _buildSearch(ThemeData theme, TrackPersonViewModel model) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: model.searchController,
              onTap: model.showUserDropdown,
              onChanged: model.filterUsers,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                hintText: "Search employee...",
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFB0B7C3),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (model.searchController.text.isNotEmpty)
            GestureDetector(
              onTap: model.clearSearch,
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Color(0xFF9CA3AF)),
              ),
            ),
          GestureDetector(
            onTap: model.toggleDropdown,
            child: Container(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                model.showDropdown
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DROPDOWN ─────────────────────────────────────────────────────────────

  Widget _buildDropdown(ThemeData theme, TrackPersonViewModel model) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: model.filteredUsers.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                "No employees found",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            itemCount: model.filteredUsers.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 56,
              color: Color(0xFFF3F4F6),
            ),
            itemBuilder: (_, i) {
              final name = model.filteredUsers[i];
              final initials = name
                  .split(' ')
                  .take(2)
                  .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                  .join();
              return ListTile(
                dense: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFFD1D5DB),
                ),
                onTap: () => model.selectUser(name),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── MAP CARD ─────────────────────────────────────────────────────────────

  Widget _buildMapCard(
      BuildContext context, ThemeData theme, TrackPersonViewModel model) {
    final size = MediaQuery.sizeOf(context);
    final mapHeight = (size.height * 0.45).clamp(280.0, 420.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map
          SizedBox(
            height: mapHeight,
            child: Stack(
              children: [
                Builder(builder: (_) {
                  final user = model.userInfo.value;
                  final pts = model.routePoints.value;

                  if (user.lat == 0 || user.lng == 0) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4F46E5),
                      ),
                    );
                  }

                  return GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(user.lat, user.lng),
                      zoom: 15,
                    ),
                    onMapCreated: (c) => model.gMapController = c,
                    markers: {
                      Marker(
                        markerId: const MarkerId("user"),
                        position: LatLng(user.lat, user.lng),
                      ),
                    },
                    polylines: {
                      if (model.isTrackingStarted && pts.length >= 2)
                        Polyline(
                          polylineId: const PolylineId("route"),
                          points: pts,
                          width: 5,
                          color: const Color(0xFF4F46E5),
                        ),
                    },
                  );
                }),

                // Live badge (top-left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _LiveBadge(
                    isTracking: model.isTrackingStarted,
                    pulseAnim: _pulseAnim,
                  ),
                ),

                // Waypoint button (top-right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WaypointPage(user: model.selectedUser),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.route_rounded,
                              size: 14, color: Color(0xFF4F46E5)),
                          SizedBox(width: 5),
                          Text(
                            "Waypoints",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Start / Tracking button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: _buildTrackButton(model),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackButton(TrackPersonViewModel model) {
    final isLoading = model.userInfo.value.lat == 0;

    if (model.isTrackingStarted) {
      return Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFF22C55E),
                    const Color(0xFF86EFAC),
                    _pulseAnim.value,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Tracking Active",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF15803D),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : model.startTracking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          disabledBackgroundColor: const Color(0xFFE5E7EB),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF9CA3AF),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          isLoading ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded,
          size: 18,
        ),
        label: Text(
          isLoading ? "Loading location..." : "Start Tracking",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  // ── INFO CARD ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(
      BuildContext context, ThemeData theme, TrackPersonViewModel model) {
    final initials = model.selectedUser
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.selectedUser,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ValueListenableBuilder(
                      valueListenable: model.userInfo,
                      builder: (_, user, __) => Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: user.lat != 0
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFD1D5DB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            user.lat != 0 ? "Location active" : "Waiting...",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: model.distanceKm,
                  builder: (_, d, __) => _MetricTile(
                    icon: Icons.route_outlined,
                    label: "Distance",
                    value: d == 0 ? "—" : "${d.toStringAsFixed(2)} km",
                    iconColor: const Color(0xFF4F46E5),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: model.userInfo,
                  builder: (_, user, __) => _MetricTile(
                    icon: Icons.battery_charging_full_rounded,
                    label: "Battery",
                    value: user.battery == 0 ? "—" : "${user.battery}%",
                    iconColor: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                    trailing: user.battery != 0
                        ? _BatteryBar(level: user.battery / 100)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Address
          ValueListenableBuilder<String>(
            valueListenable: model.destinationAddress,
            builder: (_, address, __) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.isEmpty ? "Fetching address..." : address,
                        style: TextStyle(
                          fontSize: 13,
                          color: address.isEmpty
                              ? const Color(0xFFB0B7C3)
                              : const Color(0xFF374151),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── REUSABLE WIDGETS ─────────────────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isTracking;
  final Animation<double> pulseAnim;

  const _LiveBadge({required this.isTracking, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTracking
                    ? Color.lerp(
                  const Color(0xFF22C55E),
                  const Color(0xFF86EFAC),
                  pulseAnim.value,
                )
                    : const Color(0xFFD1D5DB),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isTracking ? "Live" : "Ready",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isTracking
                  ? const Color(0xFF15803D)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;
  final Widget? trailing;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: iconColor.withOpacity(0.7),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(height: 6),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  final double level; // 0.0 – 1.0

  const _BatteryBar({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = level > 0.5
        ? const Color(0xFF22C55E)
        : level > 0.2
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: level,
        minHeight: 4,
        backgroundColor: Colors.white.withOpacity(0.6),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}