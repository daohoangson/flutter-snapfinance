import 'dart:async';

import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/firebase/db/add_transaction_command.dart';
import 'package:snapfinance/3rdparty/firebase/storage/upload_file_command.dart';
import 'package:snapfinance/3rdparty/ml/find_numbers_command.dart';

class SnapServices {
  final _addTransactionCommand =
      StreamController<AddTransactionCommand>.broadcast();
  final _findNumbersCommand = StreamController<FindNumbersCommand>.broadcast();
  final _takePhotoCommand = StreamController<TakePhotoCommand>.broadcast();
  final _uploadFileCommand = StreamController<UploadFileCommand>.broadcast();

  Stream<AddTransactionCommand>? get addTransactionCommands =>
      _addTransactionCommand.stream;

  Stream<FindNumbersCommand>? get findNumbersCommands =>
      _findNumbersCommand.stream;

  Stream<TakePhotoCommand>? get takePhotoCommands => _takePhotoCommand.stream;

  Stream<UploadFileCommand>? get uploadFileCommands =>
      _uploadFileCommand.stream;

  void dispose() {
    _addTransactionCommand.close();
    _findNumbersCommand.close();
    _takePhotoCommand.close();
    _uploadFileCommand.close();
  }

  void addTransaction(AddTransactionCommand cmd) {
    _addTransactionCommand.add(cmd);
  }

  void findNumbers(FindNumbersCommand cmd) {
    _findNumbersCommand.add(cmd);
  }

  void takePhoto(TakePhotoCommand cmd) {
    _takePhotoCommand.add(cmd);
  }

  void uploadFile(UploadFileCommand cmd) {
    _uploadFileCommand.add(cmd);
  }
}
