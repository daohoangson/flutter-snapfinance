import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/3rdparty/ml/ocr_service.dart';

class OnDeviceOcr implements OcrService {
  @override
  Stream<OcrNumber> findNumbers(String path) async* {
    final startedAt = DateTime.now();
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw StateError('findNumbers: rootIsolateToken == null');
    }

    final receivePort = ReceivePort();
    final controller = StreamController<OcrNumber>();
    await Isolate.spawn(
      _isolateFindNumbers,
      [rootIsolateToken, receivePort.sendPort, path],
    );
    receivePort.listen((message) {
      if (message == _isolateDone) {
        receivePort.close();
        controller.close();
        final duration = DateTime.now().difference(startedAt);
        debugPrint('findNumbers: duration=$duration');
      } else {
        Map<String, dynamic> json = jsonDecode(message);
        controller.add(OcrNumber.fromJson(json));
      }
    });

    yield* controller.stream;
  }
}

const _isolateDone = 'Isolate: done';

Future<void> _isolateFindNumbers(List<Object> args) async {
  final rootIsolateToken = args[0] as RootIsolateToken;
  final sendPort = args[1] as SendPort;
  final path = args[2] as String;

  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  final inputImage = InputImage.fromFilePath(path);
  final textRecognizer = TextRecognizer();
  final recognizedText = await textRecognizer.processImage(inputImage);
  final numbers = RegExp(r'^(VND|VNĐ)?([0-9,. ]+)(VND|VNĐ|đ|d)?$');
  final notNumbers = RegExp('[,. ]');

  for (final block in recognizedText.blocks) {
    for (final line in block.lines) {
      final numberMatch = numbers.matchAsPrefix(line.text);
      if (numberMatch == null) {
        debugPrint('findNumbers: Ignoring ${line.text}');
        continue;
      }

      final encoded = jsonEncode({
        "cornerPoints":
            line.cornerPoints.map((p) => [p.x, p.y]).toList(growable: false),
        "text": numberMatch.group(2)!.replaceAll(notNumbers, ''),
      });
      debugPrint('findNumbers: Sending $encoded');

      sendPort.send(encoded);
    }
  }
  textRecognizer.close();

  sendPort.send(_isolateDone);
}
