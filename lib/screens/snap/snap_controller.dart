import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/firebase/db/add_transaction_command.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';
import 'package:snapfinance/3rdparty/firebase/storage/upload_file_command.dart';
import 'package:snapfinance/3rdparty/ml/find_numbers_command.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/screens/snap/snap_progress.dart';
import 'package:snapfinance/screens/snap/snap_services.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';

class SnapController {
  final SnapServices services;

  final _stateController =
      BehaviorSubject<SnapState>.seeded(SnapState.initial());
  final _totalProgress = SnapProgress();

  final _ocrResult = BehaviorSubject<List<OcrNumber>>.seeded(const []);

  SnapController(this.services);

  Stream<List<OcrNumber>> get foundNumbersStream => _ocrResult.stream;

  List<OcrNumber> get foundNumbers => _ocrResult.value;

  Stream<SnapState> get stream => _stateController.stream;

  Stream<double> get totalProgressStream => _totalProgress.stream;

  double get totalProgress => _totalProgress.value;

  SnapState get value => _stateController.value;

  void dispose() {
    _stateController.close();
    _totalProgress.close();

    _ocrResult.close();
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
        _step2UploadFile(next);
      } else {
        logger.debug('move: $previous -> $next');
      }

      next.map(
        onFailure: _doNothing,
        onInitiatingCamera: _doNothing,
        onInitializedCamera: _step0Reset,
        onTakingPhoto: _step1TakePhoto,
        onProcessingPhoto: _step2FindNumbers,
        onReviewing: _doNothing,
        onAddingTransaction: _step3AddTransaction,
        onAddedTransaction: _doNothing,
      );
    }

    return next;
  }

  void _doNothing(SnapState _) {}

  void _step0Reset(StateInitializedCamera _) {
    _ocrResult.add(const []);
    _totalProgress.reset();
  }

  void _step1TakePhoto(StateTakingPhoto value) {
    final cmd = TakePhotoCommand();
    cmd.future.then(
      (photoPath) {
        move(value, value.tookPhoto(photoPath));
        _totalProgress.tookPhoto();
      },
      onError: (error) => move(value, value.failure(error)),
    );

    services.takePhoto(cmd);
  }

  void _step2FindNumbers(StateProcessingPhoto processing) async {
    final result = StreamController<OcrNumber>();
    final cmd = FindNumbersCommand(processing.photoPath, result.sink);
    final f = cmd.future.then(
      (_) => move(processing, processing.completed()),
      onError: (error) => move(processing, processing.failure(error)),
    );
    f.then((_) {
      // finally: clean up
      result.close();
    });

    services.findNumbers(cmd);

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

  void _step2UploadFile(Step2 step2) async {
    final result = StreamController<double>();
    final cmd = UploadFileCommand(step2.photoPath, result.sink);
    services.uploadFile(cmd);

    await for (final uploadProgress in result.stream) {
      logger.verbose('uploadProgress=$uploadProgress');

      final latest = value;
      if (latest is Step2 && latest.photoPath == step2.photoPath) {
        _totalProgress.uploadProgress(uploadProgress);
      } else {
        logger.debug('_uploadFile: unexpected latest=$latest');
        break;
      }
    }
  }

  void _step3AddTransaction(StateAddingTransaction adding) async {
    final cmd = AddTransactionCommand(
      vnd: adding.vnd,
    );
    cmd.future.then(
      (transactionId) {
        move(adding, adding.addedTransaction(transactionId));
        _totalProgress.addedTransaction();
      },
      onError: (error) => move(adding, adding.failure(error)),
    );

    services.addTransaction(cmd);
  }
}
