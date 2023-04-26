import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/ml/ocr_service.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/widgets/snap_bottom_sheet.dart';
import 'package:snapfinance/screens/snap/widgets/snap_viewport.dart';
import 'package:snapfinance/widgets/fitted_preview.dart';

class SnapScreen extends StatefulWidget {
  final OcrService ocr;

  const SnapScreen({
    super.key,
    required this.ocr,
  });

  @override
  State<SnapScreen> createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen> {
  late final SnapController controller;

  @override
  void initState() {
    super.initState();
    controller = SnapController(ocr: widget.ocr);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FittedPreview(
              child: SnapViewport(controller),
            ),
          ),
          SnapBottomSheet(controller),
        ],
      ),
    );
  }
}
