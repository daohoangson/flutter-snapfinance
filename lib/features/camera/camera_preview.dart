import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapfinance/widgets/loading.dart';
import 'package:snapfinance/widgets/nope.dart';

part 'camera_command.dart';

class CameraPreview extends StatefulWidget {
  final Stream<CameraCommand> commands;

  const CameraPreview({required this.commands, super.key});

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  late StreamSubscription<CameraCommand> _commandsSubscription;

  PhotoCameraState? _photoCameraState;

  @override
  void initState() {
    super.initState();
    _commandsSubscription = widget.commands.listen(_onCameraCommand);
  }

  @override
  void didUpdateWidget(covariant CameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.commands != oldWidget.commands) {
      _commandsSubscription.cancel();
      _commandsSubscription = widget.commands.listen(_onCameraCommand);
    }
  }

  @override
  void dispose() {
    _commandsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.custom(
      aspectRatio: CameraAspectRatios.ratio_16_9,
      builder: (state, _, __) => state.when(
        onPreparingCamera: (_) => loading,
        onPhotoMode: (value) {
          // TODO: find a better way to do this, it may leak
          _photoCameraState = value;
          return nope;
        },
      ),
      saveConfig: SaveConfig.photo(pathBuilder: _pathBuilder),
    );
  }

  Future<String> _pathBuilder() async {
    final extDir = await getTemporaryDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch;
    return '${extDir.path}/$fileName.jpg';
  }

  void _onCameraCommand(CameraCommand cmd) {
    if (cmd is CommandTakePhoto) {
      _photoCameraState?.takePhoto().then(
            cmd._completer.complete,
            onError: cmd._completer.completeError,
          );
    }
  }
}
