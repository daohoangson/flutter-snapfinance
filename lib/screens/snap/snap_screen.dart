import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/firebase/storage/firebase_storage.dart';
import 'package:snapfinance/3rdparty/ml/on_device_ocr.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/widgets/snap_bottom_sheet.dart';
import 'package:snapfinance/screens/snap/widgets/snap_viewport.dart';
import 'package:snapfinance/widgets/fitted_preview.dart';
import 'package:snapfinance/widgets/upload_progress_bar.dart';

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
    Widget built = Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FittedPreview(
              child: SnapViewport(controller),
            ),
          ),
          UploadProgressBar(controller.uploadProgressStream),
          SnapBottomSheet(controller),
        ],
      ),
    );

    final findNumberCommands = controller.findNumberCommands;
    if (findNumberCommands != null) {
      built = OnDeviceOcr(
        findNumbersCommands: findNumberCommands,
        child: built,
      );
    }

    final uploadFileCommands = controller.uploadFileCommands;
    if (uploadFileCommands != null) {
      built = FirebaseStorageApp(
        uploadFileCommands: uploadFileCommands,
        child: built,
      );
    }

    return built;
  }
}
