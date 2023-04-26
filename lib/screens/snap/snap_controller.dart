import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/ml/ocr_service.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';

class SnapController {
  final OcrService ocr;

  final _cameraController = StreamController<TakePhotoCommand>.broadcast();
  final _stateController = StreamController<SnapState>.broadcast();

  SnapState _latest = SnapState.initial();

  SnapController({required this.ocr});

  Stream<SnapState> get stream => _stateController.stream;

  Stream<TakePhotoCommand> get takePhotoCommands => _cameraController.stream;

  SnapState get value => _latest;

  void dispose() {
    _cameraController.close();
    _stateController.close();
  }

  T move<T extends SnapState>(SnapState previous, T next) {
    if (previous != _latest) {
      throw StateError(
        'Mismatched previous state: actual=$previous expected=$_latest',
      );
    }

    _stateController.add(next);
    _latest = next;

    if (next.runtimeType != previous.runtimeType) {
      debugPrint('move: $previous -> $next');

      if (next is StateTakingPhoto) {
        _takePhoto(next);
      } else if (next is StateProcessingPhoto) {
        // the processing state may happen multiple times
        _findNumbers(next);
      }
    }

    return next;
  }

  void _takePhoto(StateTakingPhoto value) {
    final takePhoto = TakePhotoCommand();
    _cameraController.add(takePhoto);
    takePhoto.future.then(
      (photoPath) {
        debugPrint('photoPath=$photoPath');
        move(value, value.tookPhoto(photoPath));
      },
      onError: (error) => move(value, value.failure(error)),
    );
  }

  void _findNumbers(StateProcessingPhoto value) async {
    var processing = value;
    try {
      await for (final number in ocr.findNumbers(value.photoPath)) {
        debugPrint('number=${number.value} ${number.cornerPoints}');
        processing = move(processing, processing.foundNumber(number));
      }
      move(processing, processing.completed());
    } catch (error) {
      move(processing, processing.failure(error));
    }
  }
}
