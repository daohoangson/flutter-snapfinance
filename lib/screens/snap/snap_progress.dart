import 'dart:async';

import 'package:rxdart/rxdart.dart';

const _progressTookPhoto = .25;
const _progressUploadedFile = .75;
const _progressAddedTransaction = 1.0;

class SnapProgress {
  final _totalController = BehaviorSubject<double>.seeded(.0);
  final _uploadController = BehaviorSubject<double>.seeded(.0);

  Stream<double> get stream => _totalController.stream;

  Stream<double> get uploadStream => _uploadController.stream;

  double get upload => _uploadController.value;

  double get value => _totalController.value;

  void close() {
    _totalController.close();
  }

  void reset() {
    _totalController.add(.0);
    _uploadController.add(.0);
  }

  void tookPhoto() {
    _totalController.add(_progressTookPhoto);
  }

  void uploadProgress(double value) {
    const previousSteps = _progressTookPhoto;
    const thisStep = _progressUploadedFile - previousSteps;
    _totalController.add(previousSteps + thisStep * value);
    _uploadController.add(value);
  }

  void addedTransaction() {
    _totalController.add(_progressAddedTransaction);
  }
}
