part of 'camera_preview.dart';

abstract class CameraCommand {}

class CommandTakePhoto extends CameraCommand {
  final _completer = Completer<String>();

  Future<String> get future => _completer.future;

  CommandTakePhoto();
}
