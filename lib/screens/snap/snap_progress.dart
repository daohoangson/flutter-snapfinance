import 'dart:async';

import 'package:rxdart/rxdart.dart';

const _progressTookPhoto = .25;
const _progressUploadedFile = .75;
const _progressAddedTransaction = 1.0;

class SnapProgress {
  final controller = BehaviorSubject<double>.seeded(.0);

  Stream<double> get stream => controller.stream;

  double get value => controller.value;

  void close() {
    controller.close();
  }

  void reset() {
    controller.add(.0);
  }

  void tookPhoto() {
    controller.add(_progressTookPhoto);
  }

  void uploadProgress(double value) {
    const previousSteps = _progressTookPhoto;
    const thisStep = _progressUploadedFile - previousSteps;
    controller.add(previousSteps + thisStep * value);
  }

  void addedTransaction() {
    controller.add(_progressAddedTransaction);
  }
}
