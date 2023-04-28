import 'dart:async';

class UploadFileCommand {
  final String path;
  final EventSink<double>? progress;

  UploadFileCommand(this.path, this.progress);
}
