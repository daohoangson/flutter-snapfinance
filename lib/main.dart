import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapfinance/features/camera/camera_preview.dart';
import 'package:snapfinance/features/ml/ocr_number.dart';
import 'package:snapfinance/features/ml/on_device_ml.dart';
import 'package:snapfinance/features/vnd/vnd_input.dart';
import 'package:snapfinance/features/vnd/vnd_preview.dart';
import 'package:snapfinance/widgets/fitted_preview.dart';
import 'package:snapfinance/widgets/image_viewer.dart';
import 'package:snapfinance/widgets/ok_again_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Finance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SnapScreen(),
    );
  }
}

class SnapScreen extends StatefulWidget {
  const SnapScreen({super.key});

  @override
  State<SnapScreen> createState() => _SnapScreenState();
}

class _SnapScreenState extends State<SnapScreen> {
  final cameraController = StreamController<CameraCommand>.broadcast();
  final numberController = StreamController<OcrNumber>.broadcast();

  int? _vnd;
  String? _photoPath;

  @override
  Widget build(BuildContext context) {
    final photoPath = _photoPath;
    final vnd = _vnd;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FittedPreview(
              child: photoPath == null
                  ? CameraPreview(commands: cameraController.stream)
                  : InteractiveViewer(
                      child: ImageViewer(
                        numbers: numberController.stream,
                        onVnd: (vnd) => setState(() => _vnd = vnd),
                        path: photoPath,
                      ),
                    ),
            ),
          ),
          vnd == null
              ? VndInput(
                  onDone: _takePhoto,
                  vndBuilder: VndPreview.new,
                )
              : Column(
                  children: [
                    VndPreview.vnd(vnd),
                    OkAgainInput(
                      onAgain: _again,
                      onOk: () {},
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _again() {
    setState(() {
      _photoPath = null;
      _vnd = null;
    });
  }

  void _takePhoto(int vnd) async {
    setState(() {
      _vnd = vnd;
    });

    final takePhoto = CommandTakePhoto();
    cameraController.add(takePhoto);
    final path = await takePhoto.future;
    debugPrint('path=$path');

    setState(() {
      _photoPath = path;
    });

    if (vnd == 0) {
      await for (final number in findNumbers(path)) {
        debugPrint('number=${number.value} ${number.cornerPoints}');
        numberController.add(number);
      }
    }
  }
}
