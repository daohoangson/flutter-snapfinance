import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';

const assetNameMidjourney = 'assets/placeholders/midjourney.png';
const assetNameReddit = 'assets/placeholders/reddit.jpg';
const assetNames = [
  assetNameMidjourney,
  assetNameReddit,
];

@visibleForTesting
int? debugRandomSeed;

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

    final assetNameId = Random(debugRandomSeed).nextInt(assetNames.length);
    assetName = assetNames[assetNameId];

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
      child: Image.asset(
        assetName,
        fit: BoxFit.cover,
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
      } catch (error) {
        cmd.completer.completeError(error);
      }
    });
  }
}
