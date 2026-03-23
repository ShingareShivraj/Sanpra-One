import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:stacked/stacked.dart';

import 'waypoint_viewmodel.dart';

class WaypointPage extends StatelessWidget {
  final String user;

  const WaypointPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WaypointViewModel>.reactive(
      viewModelBuilder: () => WaypointViewModel(user),
      onViewModelReady: (model) async {
        await model.init();

        // 🧠 wait for UI to render
        WidgetsBinding.instance.addPostFrameCallback((_) async {

          model.isMapReady = true;

          await Future.delayed(const Duration(milliseconds: 300));

          if (model.routePoints.isNotEmpty || model.waypoints.isNotEmpty) {
            final bounds = model.getBounds();

            model.mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(80),
              ),
            );
          }

          print("✅ MAP IS READY NOW");
        });
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Travel History"),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => model.pickDate(context),
              )
            ],
          ),

          body: model.isBusy
              ? const Center(child: CircularProgressIndicator())
              :Stack(
            children: [

              FlutterMap(
                mapController: model.mapController,
                options: MapOptions(
                  initialCenter: model.initialPosition,
                  initialZoom: 15,

                ),
                children: [

                  TileLayer(
                    urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.sanpra.salesapp',
                  ),

                  if (model.routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: model.routePoints,
                          strokeWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: model.waypoints.asMap().entries.map((entry) {
                      int i = entry.key;
                      final wp = entry.value;

                      Color color;

                      if (i == 0) {
                        color = Colors.green;
                      } else if (i == model.waypoints.length - 1) {
                        color = Colors.red;
                      } else {
                        color = Colors.blue;
                      }

                      return Marker(
                        point: wp.position,
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text("Details"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reference Type: ${wp.referenceType}",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Reference Name: ${wp.referenceName}",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Description: ${wp.description}",
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${i + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // 📍 DISTANCE CARD (TOP RIGHT)
              Positioned(
                top: 20,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  child: Text(
                    "${model.totalDistance.toStringAsFixed(2)} km",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: model.startAnimation,
            child: const Icon(Icons.play_arrow),
          ),
        );
      },
    );
  }
}