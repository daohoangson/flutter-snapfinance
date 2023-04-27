import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';
import 'package:snapfinance/3rdparty/firebase/storage/upload_file_command.dart';
import 'package:snapfinance/3rdparty/ml/find_numbers_command.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';

class SnapController {
  final _stateController =
      BehaviorSubject<SnapState>.seeded(SnapState.initial());

  final _cameraController = StreamController<TakePhotoCommand>.broadcast();
  final _ocrController = StreamController<FindNumbersCommand>.broadcast();
  final _ocrResult = BehaviorSubject<List<OcrNumber>>.seeded(const []);
  final _storageController = StreamController<UploadFileCommand>.broadcast();
  final _storageProgress = BehaviorSubject<double>.seeded(.0);

  Stream<FindNumbersCommand>? get findNumberCommands => _ocrController.stream;

  Stream<List<OcrNumber>> get foundNumbersStream => _ocrResult.stream;

  List<OcrNumber> get foundNumbers => _ocrResult.value;

  Stream<SnapState> get stream => _stateController.stream;

  Stream<TakePhotoCommand>? get takePhotoCommands => _cameraController.stream;

  Stream<UploadFileCommand>? get uploadFileCommands =>
      _storageController.stream;

  Stream<double> get uploadProgressStream => _storageProgress.stream;

  double get uploadProgress => _storageProgress.value;

  SnapState get value => _stateController.value;

  void dispose() {
    _stateController.close();

    _cameraController.close();
    _ocrController.close();
    _ocrResult.close();
    _storageController.close();
    _storageProgress.close();
  }

  T move<T extends SnapState>(SnapState previous, T next) {
    final latest = value;
    if (!identical(previous, latest)) {
      throw StateError('Mismatched previous state: $previous <> $latest');
    }

    _stateController.add(next);

    if (next.runtimeType != previous.runtimeType) {
      if (previous is StateTakingPhoto && next is Step2) {
        logger.debug('move & upload file: $previous -> $next');
        _uploadFile(next);
      } else {
        logger.debug('move: $previous -> $next');
      }

      if (next is StateInitializedCamera) {
        _ocrResult.add(const []);
        _storageProgress.add(.0);
      } else if (next is StateTakingPhoto) {
        _takePhoto(next);
      } else if (next is StateProcessingPhoto) {
        _findNumbers(next);
      }
    }

    return next;
  }

  void _takePhoto(StateTakingPhoto value) {
    final takePhoto = TakePhotoCommand();
    takePhoto.future.then(
      (photoPath) => move(value, value.tookPhoto(photoPath)),
      onError: (error) => move(value, value.failure(error)),
    );

    _cameraController.add(takePhoto);
  }

  void _findNumbers(StateProcessingPhoto processing) async {
    final result = StreamController<OcrNumber>();
    final findNumbers = FindNumbersCommand(processing.photoPath, result.sink);
    final f = findNumbers.future.then(
      (_) => move(processing, processing.completed()),
      onError: (error) => move(processing, processing.failure(error)),
    );
    f.then((_) {
      // finally: clean up
      result.close();
    });

    _ocrController.add(findNumbers);

    var numbers = <OcrNumber>[];
    await for (final number in result.stream) {
      logger.verbose('number=${number.value} ${number.cornerPoints}');

      final latest = value;
      if (latest is! Step2 || latest.photoPath != processing.photoPath) {
        logger.debug('_findNumbers: unexpected latest=$latest');
        continue;
      }

      const min5k = 5000;
      const max50mil = 50000000;
      if (number.value < min5k || number.value > max50mil) {
        // ignore random numbers
        continue;
      }

      final isExisting =
          numbers.where((n) => n.value == number.value).isNotEmpty;
      if (isExisting) {
        // keep each value only once to reduce UI noise
        continue;
      }

      numbers = [...numbers, number];
      _ocrResult.add(numbers);
    }
  }

  void _uploadFile(Step2 step2) async {
    final result = StreamController<double>();
    final uploadFile = UploadFileCommand(step2.photoPath, result.sink);

    _storageController.add(uploadFile);

    await for (final progress in result.stream) {
      logger.verbose('progress=$progress');

      final latest = value;
      if (latest is Step2 && latest.photoPath == step2.photoPath) {
        _storageProgress.add(progress);
      } else {
        logger.debug('_uploadFile: unexpected latest=$latest');
        break;
      }
    }
  }
}
