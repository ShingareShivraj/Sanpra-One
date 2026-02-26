import 'package:flutter/material.dart';
import 'package:geolocation/screens/visit_screens/update_visit/update_visit_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

import '../../../widgets/full_screen_loader.dart';

class UpdateVisitScreen extends StatefulWidget {
  final String updateId;
  const UpdateVisitScreen({super.key, required this.updateId});

  @override
  State<UpdateVisitScreen> createState() => _UpdateVisitScreenState();
}

class _UpdateVisitScreenState extends State<UpdateVisitScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget? _visitInMap;
  Widget? _visitOutMap;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ViewModelBuilder<UpdateVisitModel>.reactive(
      viewModelBuilder: () => UpdateVisitModel(),
      onViewModelReady: (model) => model.initialise(context, widget.updateId),
      builder: (context, model, child) {
        _buildMapsOnce(model);

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            elevation: 0.5,
            title: Text(
              model.visitData.name ?? "Visit Details",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _infoCard(
                  icon: Icons.person,
                  label: "Visitor",
                  value: model.visitData.visitorsName,
                ),
                _infoCard(
                  icon: Icons.description_outlined,
                  label: "Purpose",
                  value: model.visitData.description,
                ),
                _visitImageCard(model.visitData.attachmentUrl),
                _timelineSection(
                  title: "Visit In",
                  color: Colors.green,
                  time: model.visitData.visitInTime,
                  map: _visitInMap,
                  address: model.visitData.visitInAddress,
                ),
                _timelineSection(
                  title: "Visit Out",
                  color: Colors.red,
                  time: model.visitData.visitOutTime,
                  map: _visitOutMap,
                  address: model.visitData.visitOutAddress,
                ),
                _infoCard(
                  icon: Icons.badge_outlined,
                  label: "Employee",
                  value: model.visitData.employee,
                ),
                _infoCard(
                  icon: Icons.account_circle_outlined,
                  label: "User",
                  value: model.visitData.user,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= MAPS =================

  void _buildMapsOnce(UpdateVisitModel model) {
    if (_visitInMap == null &&
        model.visitData.visitInLatitude?.isNotEmpty == true &&
        model.visitData.visitInLongitude?.isNotEmpty == true) {
      _visitInMap = _mapView(
        LatLng(
          double.parse(model.visitData.visitInLatitude!),
          double.parse(model.visitData.visitInLongitude!),
        ),
        "visit_in",
      );
    }

    if (_visitOutMap == null &&
        model.visitData.visitOutLatitude?.isNotEmpty == true &&
        model.visitData.visitOutLongitude?.isNotEmpty == true) {
      _visitOutMap = _mapView(
        LatLng(
          double.parse(model.visitData.visitOutLatitude!),
          double.parse(model.visitData.visitOutLongitude!),
        ),
        "visit_out",
      );
    }
  }

  Widget _mapView(LatLng position, String id) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 15),
          markers: {
            Marker(markerId: MarkerId(id), position: position),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  // ================= INFO CARD =================

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    if (value == null || value.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= TIMELINE =================

  Widget _timelineSection({
    required String title,
    required Color color,
    String? time,
    Widget? map,
    String? address,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 18,
                  child: const Icon(Icons.access_time,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            if (time != null) ...[
              const SizedBox(height: 10),
              _pill(Icons.schedule, _formatDate(time)),
            ],
            if (map != null) ...[
              const SizedBox(height: 10),
              map,
            ],
            if (address?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              _pill(Icons.location_on_outlined, address!),
            ],
          ],
        ),
      ),
    );
  }

  // ================= PILL =================

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================

  Widget _visitImageCard(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
          errorBuilder: (_, __, ___) => const SizedBox(
            height: 200,
            child: Center(child: Icon(Icons.broken_image, size: 40)),
          ),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    try {
      final dt = DateTime.parse(value);
      return "${dt.day}-${dt.month}-${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return value;
    }
  }
}
