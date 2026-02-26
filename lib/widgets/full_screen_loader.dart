import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants.dart';

Widget fullScreenLoader({
  required bool loader,
  required Widget child,
  required BuildContext context,
}) {
  return Stack(
    children: [
      child,
      if (loader)
        Container(
          height: getHeight(context),
          width: getWidth(context),
          color: Colors.black.withOpacity(0.4),
          child: const Center(
            child: _ProcessingDialog(),
          ),
        ),
    ],
  );
}

class _ProcessingDialog extends StatefulWidget {
  const _ProcessingDialog();

  @override
  State<_ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnim = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.teal,
    ).animate(_controller);

    _animateDots();
  }

  void _animateDots() async {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return; // ✅ SAFE EXIT

      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
    }
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitFadingCircle(
            color: Colors.blueAccent,
            size: 45,
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _colorAnim,
            builder: (_, __) {
              return Text(
                "Processing${"." * dotCount}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _colorAnim.value,
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Text(
            "Please wait",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
