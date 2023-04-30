import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';
import 'package:snapfinance/widgets/test_indicator.dart';

@visibleForTesting
const assetNameWhite = 'assets/placeholders/white.png';
const _assetNames = [
  'assets/placeholders/android_up.jpg',
  'assets/placeholders/android_left.jpg',
  'assets/placeholders/android_right.jpg',
  'assets/placeholders/iphone_up.jpg',
  'assets/placeholders/iphone_left.jpg',
  'assets/placeholders/iphone_right.jpg',
];

@visibleForTesting
String? debugAssetName;

@visibleForTesting
var debugTriggerOnInitialized = true;

class FakeCameraPreview extends StatefulWidget {
  final VoidCallback? onInitialized;
  final Stream<TakePhotoCommand>? takePhotoCommands;

  const FakeCameraPreview({
    super.key,
    required this.onInitialized,
    required this.takePhotoCommands,
  });

  @override
  State<FakeCameraPreview> createState() => _FakeCameraPreviewState();
}

class _FakeCameraPreviewState extends State<FakeCameraPreview> {
  late final String assetName;

  StreamSubscription<TakePhotoCommand>? _takePhotoCommands;

  @override
  void initState() {
    super.initState();

    final assetNameId = Random().nextInt(_assetNames.length);
    assetName = debugAssetName ?? _assetNames[assetNameId];

    _takePhotoCommands = widget.takePhotoCommands?.listen(_onTakePhoto);

    if (debugTriggerOnInitialized) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onInitialized?.call());
    }
  }

  @override
  void didUpdateWidget(covariant FakeCameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.takePhotoCommands != oldWidget.takePhotoCommands) {
      _takePhotoCommands?.cancel();
      _takePhotoCommands = widget.takePhotoCommands?.listen(_onTakePhoto);
    }
  }

  @override
  void dispose() {
    _takePhotoCommands?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              assetName,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: TestIndicator(
              animate: debugAssetName == null,
              text: 'Fake camera',
            ),
          ),
        ],
      ),
    );
  }

  void _onTakePhoto(TakePhotoCommand cmd) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final byteData = await rootBundle.load(assetName);
      final buffer = byteData.buffer;
      final extDir = await getTemporaryDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch;
      final path = p.join(extDir.path, '$fileName.jpg');
      final file = File(path);
      try {
        await file.writeAsBytes(
          buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
        cmd.completer.complete(path);
        logger.verbose('_onTakePhoto: path=$path');
      } catch (error) {
        cmd.completer.completeError(error);
      }
    });
  }
}
