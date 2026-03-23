import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocation/widgets/full_screen_loader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

import 'track_page_viewmodel.dart';
import 'waypoint_page.dart';

class TrackPersonPage extends StatelessWidget {
  const TrackPersonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<TrackPersonViewModel>.reactive(
      viewModelBuilder: () => TrackPersonViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Track Person"),
            actions: [
              IconButton(
                tooltip: "Refresh users",
                onPressed: model.fetchUsers,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: "Clear",
                onPressed: model.clearSelection,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          body: fullScreenLoader(
            context: context,
            loader: model.isBusy,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSearch(theme, model),
                const SizedBox(height: 10),
                if (model.showDropdown) _buildDropdown(theme, model),
                const SizedBox(height: 12),
                if (model.selectedUser.isNotEmpty)
                  _buildGoogleMap(context, theme, model),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔍 SEARCH
  Widget _buildSearch(ThemeData theme, TrackPersonViewModel model) {
    return TextField(
      controller: model.searchController,
      onTap: model.showUserDropdown,
      onChanged: model.filterUsers,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        hintText: "Search employee",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (model.searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: model.clearSearch,
              ),
            IconButton(
              icon: Icon(
                  model.showDropdown ? Icons.expand_less : Icons.expand_more),
              onPressed: model.toggleDropdown,
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // 👤 DROPDOWN
  Widget _buildDropdown(ThemeData theme, TrackPersonViewModel model) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: model.filteredUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No users found"),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: model.filteredUsers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final name = model.filteredUsers[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => model.selectUser(name),
                    );
                  },
                ),
        ),
      ),
    );
  }

  // 🗺 GOOGLE MAP + INFO
  Widget _buildGoogleMap(
      BuildContext context, ThemeData theme, TrackPersonViewModel model) {
    final size = MediaQuery.sizeOf(context);
    final mapHeight = (size.height * 0.55).clamp(320.0, 520.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: mapHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ValueListenableBuilder<List<LatLng>>(
              valueListenable: model.routePoints,
              builder: (_, pts, __) {
                return GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        model.userInfo.value.lat, model.userInfo.value.lng),
                    zoom: 15,
                  ),
                  onMapCreated: (c) => model.gMapController = c,
                  onCameraMoveStarted: () {
                    model.autoFollowEnabled = false;
                    model.cameraIdleTimer?.cancel();
                  },
                  onCameraIdle: () {
                    model.cameraIdleTimer?.cancel();
                    model.cameraIdleTimer =
                        Timer(const Duration(seconds: 5), () {
                      model.autoFollowEnabled = true;
                      model.maybeFollowGoogle();
                    });
                  },
                  markers: {
                    if (model.userInfo.value.lat != 0)
                      Marker(
                        markerId: const MarkerId("user"),
                        position: LatLng(
                          model.userInfo.value.lat,
                          model.userInfo.value.lng,
                        ),
                        infoWindow: InfoWindow(title: model.selectedUser),
                      ),
                  },
                  polylines: {
                    if (pts.length >= 2)
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: pts,
                        width: 6,
                        color: Colors.blue,
                      ),
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoBelowMap(context, theme, model),
      ],
    );
  }

  // 📊 INFO CARD
  Widget _buildInfoBelowMap(
      BuildContext context,
      ThemeData theme,
      TrackPersonViewModel model,
      ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    model.selectedUser,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: model.distanceKm,
                    builder: (_, d, __) {
                      return _miniMetric(
                        theme,
                        Icons.route_outlined,
                        d == 0 ? "--" : "${d.toStringAsFixed(2)} km",
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: model.userInfo,
                    builder: (_, u, __) {
                      return _miniMetric(
                        theme,
                        Icons.battery_full,
                        u.battery == 0 ? "--" : "${u.battery}%",
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ValueListenableBuilder<String>(
              valueListenable: model.destinationAddress,
              builder: (_, address, __) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    address.isEmpty ? "Fetching address..." : address,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ✅ BUTTON
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WaypointPage(user: model.selectedUser),
                  ),
                );
              },
              icon: const Icon(Icons.route),
              label: const Text("View Travel History"),
            ),
          ],
        ),
      ),
    );
  }

  //==========================adding the new feature============================


  Widget _miniMetric(ThemeData theme, IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
