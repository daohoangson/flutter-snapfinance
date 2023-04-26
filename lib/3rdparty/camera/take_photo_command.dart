import 'dart:async';

class TakePhotoCommand {
  final completer = Completer<String>();

  Future<String> get future => completer.future;
}
