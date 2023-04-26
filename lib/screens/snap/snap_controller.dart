import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/ml/find_numbers_command.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';

class SnapController {
  final _cameraController = StreamController<TakePhotoCommand>.broadcast();
  final _ocrController = StreamController<FindNumbersCommand>.broadcast();
  final _stateController = StreamController<SnapState>.broadcast();

  SnapState _latest = SnapState.initial();

  Stream<FindNumbersCommand> get findNumberCommands => _ocrController.stream;

  Stream<SnapState> get stream => _stateController.stream;

  Stream<TakePhotoCommand> get takePhotoCommands => _cameraController.stream;

  SnapState get value => _latest;

  void dispose() {
    _cameraController.close();
    _ocrController.close();
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
    takePhoto.future.then(
      (photoPath) {
        debugPrint('photoPath=$photoPath');
        move(value, value.tookPhoto(photoPath));
      },
      onError: (error) => move(value, value.failure(error)),
    );

    _cameraController.add(takePhoto);
  }

  void _findNumbers(StateProcessingPhoto value) async {
    var processing = value;

    final result = StreamController<OcrNumber>();
    final findNumbers = FindNumbersCommand(value.photoPath, result.sink);
    final f = findNumbers.future.then(
      (_) => move(processing, processing.completed()),
      onError: (error) => move(processing, processing.failure(error)),
    );
    f.then((_) {
      // finally: clean up
      result.close();
    });

    _ocrController.add(findNumbers);

    await for (final number in result.stream) {
      debugPrint('number=${number.value} ${number.cornerPoints}');
      processing = move(processing, processing.foundNumber(number));
    }
  }
}
