import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/camera/camera_preview.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';
import 'package:snapfinance/widgets/image_viewer.dart';

class SnapViewport extends StatelessWidget {
  final SnapController controller;

  const SnapViewport(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) => _buildSnapState(snapshot.requireData),
      initialData: controller.value,
      stream: controller.stream,
    );
  }

  Widget _buildSnapState(SnapState value) {
    return value.map(
      onFailure: (_) => _buildSnapState(_.previous),
      onInitiatingCamera: (_) => CameraPreview(
        onInitialized: () => controller.move(_, _.initialized()),
      ),
      onInitializedCamera: (_) => CameraPreview(
        takePhotoCommands: controller.takePhotoCommands,
      ),
      onTakingPhoto: (_) => const CameraPreview(),
      onProcessingPhoto: (processing) => _buildImageViewer(processing),
      onReviewing: (reviewing) => _buildImageViewer(
        reviewing,
        onNumberPressed: (v) => controller.move(reviewing, reviewing.setVnd(v)),
      ),
    );
  }

  Widget _buildImageViewer(Step2 value, {Function(int)? onNumberPressed}) =>
      StreamBuilder(
        builder: (context, snapshot) => ImageViewer(
          numbers: snapshot.requireData,
          onNumberPressed: onNumberPressed,
          path: value.photoPath,
        ),
        initialData: controller.foundNumbers,
        stream: controller.foundNumbersStream,
      );
}
