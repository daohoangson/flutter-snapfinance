import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapfinance/widgets/loading.dart';
import 'package:snapfinance/widgets/nope.dart';

part 'take_photo_command.dart';

class CameraPreview extends StatefulWidget {
  final VoidCallback? onInitialized;
  final Stream<TakePhotoCommand>? takePhotoCommands;

  const CameraPreview({
    super.key,
    this.onInitialized,
    this.takePhotoCommands,
  });

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  PhotoCameraState? _photoCameraState;
  StreamSubscription<TakePhotoCommand>? _takePhotoCommands;

  @override
  void initState() {
    super.initState();
    _takePhotoCommands = widget.takePhotoCommands?.listen(_onTakePhoto);
  }

  @override
  void didUpdateWidget(covariant CameraPreview oldWidget) {
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
    return CameraAwesomeBuilder.custom(
      aspectRatio: CameraAspectRatios.ratio_16_9,
      builder: (state, _, __) => state.when(
        onPreparingCamera: (_) => loading,
        onPhotoMode: (value) {
          var wasAlreadyInitialized = _photoCameraState != null;

          // TODO: find a better way to do this, it may leak
          _photoCameraState = value;

          final onInitialized = widget.onInitialized;
          if (!wasAlreadyInitialized && onInitialized != null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => onInitialized());
          }

          return nope;
        },
      ),
      exifPreferences: ExifPreferences(saveGPSLocation: true),
      saveConfig: SaveConfig.photo(pathBuilder: _pathBuilder),
    );
  }

  Future<String> _pathBuilder() async {
    final extDir = await getTemporaryDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch;
    return '${extDir.path}/$fileName.jpg';
  }

  void _onTakePhoto(TakePhotoCommand cmd) {
    _photoCameraState?.takePhoto().then(
          cmd._completer.complete,
          onError: cmd._completer.completeError,
        );
  }
}
