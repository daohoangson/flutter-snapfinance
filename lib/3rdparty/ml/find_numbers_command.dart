import 'dart:async';

import 'package:snapfinance/3rdparty/ml/ocr_number.dart';

class FindNumbersCommand {
  final completer = Completer<void>();

  final String path;
  final Sink<OcrNumber> sink;

  FindNumbersCommand(this.path, this.sink);

  Future<void> get future => completer.future;
}
