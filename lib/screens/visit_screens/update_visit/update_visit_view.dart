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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  Widget? _visitInMap;
  Widget? _visitOutMap;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Design tokens
  static const Color _primary = Color(0xFF1A56DB);
  static const Color _primaryLight = Color(0xFF3B76EF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _background = Color(0xFFF0F4FA);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _visitInColor = Color(0xFF059669);
  static const Color _visitOutColor = Color(0xFFDC2626);
  static const Color _divider = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ViewModelBuilder<UpdateVisitModel>.reactive(
      viewModelBuilder: () => UpdateVisitModel(),
      onViewModelReady: (model) => model.initialise(context, widget.updateId),
      builder: (context, model, child) {
        _buildMapsOnce(model);

        return Scaffold(
          backgroundColor: _background,
          body: fullScreenLoader(
            loader: model.isBusy,
            context: context,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(model),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        _buildBodyContent(model),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // SLIVER APP BAR
  // ─────────────────────────────────────────────

  Widget _buildSliverAppBar(UpdateVisitModel model) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      backgroundColor: _primary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.visitData.name ?? "Visit Details",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "Visit Details",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                top: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BODY SECTIONS
  // ─────────────────────────────────────────────

  List<Widget> _buildBodyContent(UpdateVisitModel model) {
    return [
      const SizedBox(height: 8),
      _sectionLabel("Overview"),
      _infoCard(
        icon: Icons.person_outline_rounded,
        label: "Visitor",
        value: model.visitData.visitorsName,
        accentColor: _primary,
      ),
      _infoCard(
        icon: Icons.description_outlined,
        label: "Purpose",
        value: model.visitData.description,
        accentColor: const Color(0xFF7C3AED),
      ),
      _visitImageCard(model.visitData.attachmentUrl),
      // const SizedBox(height: 8),
      // _sectionLabel("Timeline"),
      // _timelineSection(
      //   title: "Visit In",
      //   color: _visitInColor,
      //   time: model.visitData.visitInTime,
      //   map: _visitInMap,
      //   address: model.visitData.visitInAddress,
      //   icon: Icons.login_rounded,
      // ),
      // _timelineSection(
      //   title: "Visit Out",
      //   color: _visitOutColor,
      //   time: model.visitData.visitOutTime,
      //   map: _visitOutMap,
      //   address: model.visitData.visitOutAddress,
      //   icon: Icons.logout_rounded,
      // ),
      const SizedBox(height: 8),
      _sectionLabel("Assignment"),
      _infoCard(
        icon: Icons.badge_outlined,
        label: "Employee",
        value: model.visitData.employee,
        accentColor: const Color(0xFFD97706),
      ),
      _infoCard(
        icon: Icons.account_circle_outlined,
        label: "User",
        value: model.visitData.user,
        accentColor: const Color(0xFF0891B2),
      ),
    ];
  }

  // ─────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MAPS
  // ─────────────────────────────────────────────

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
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 170,
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

  // ─────────────────────────────────────────────
  // INFO CARD
  // ─────────────────────────────────────────────

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String? value,
    required Color accentColor,
  }) {
    if (value == null || value.isEmpty) return const SizedBox();

    return _AnimatedCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TIMELINE SECTION
  // ─────────────────────────────────────────────

  Widget _timelineSection({
    required String title,
    required Color color,
    String? time,
    Widget? map,
    String? address,
    required IconData icon,
  }) {
    return _AnimatedCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  if (time != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDate(time),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (map != null) ...[
                    map,
                    const SizedBox(height: 10),
                  ],
                  if (address?.isNotEmpty == true)
                    _addressPill(address!),
                  if (map == null && time == null && (address == null || address.isEmpty))
                    const Text(
                      "No data recorded",
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ADDRESS PILL
  // ─────────────────────────────────────────────

  Widget _addressPill(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on_rounded, size: 12, color: _primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // IMAGE CARD
  // ─────────────────────────────────────────────

  Widget _visitImageCard(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox();

    return _AnimatedCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.image_outlined,
                        size: 18, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attachment",
                        style: TextStyle(
                          fontSize: 11,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Visit Photo",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                  height: 190,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 190,
                  child: Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 40, color: _textSecondary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DATE FORMATTER
  // ─────────────────────────────────────────────

  String _formatDate(String value) {
    try {
      final dt = DateTime.parse(value);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${dt.day} ${months[dt.month]} · $hour:${dt.minute.toString().padLeft(2, '0')} $ampm";
    } catch (_) {
      return value;
    }
  }
}

// ─────────────────────────────────────────────
// ANIMATED CARD WRAPPER (slide-up + fade-in)
// ─────────────────────────────────────────────

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  const _AnimatedCard({required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}