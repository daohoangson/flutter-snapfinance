import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/ml/on_device_ocr.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/widgets/snap_bottom_sheet.dart';
import 'package:snapfinance/screens/snap/widgets/snap_viewport.dart';
import 'package:snapfinance/widgets/fitted_preview.dart';

class SnapScreen extends StatefulWidget {
  const SnapScreen({super.key});

  @override
  State<SnapScreen> createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen> {
  final controller = SnapController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnDeviceOcr(
      findNumbersCommands: controller.findNumberCommands,
      child: Scaffold(
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
      ),
    );
  }
}
