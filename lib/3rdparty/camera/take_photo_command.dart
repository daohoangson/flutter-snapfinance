part of 'camera_preview.dart';

class TakePhotoCommand {
  final _completer = Completer<String>();

  Future<String> get future => _completer.future;
}
