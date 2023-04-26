import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:snapfinance/3rdparty/ml/find_numbers_command.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';

class OnDeviceOcr extends StatefulWidget {
  final Widget child;
  final Stream<FindNumbersCommand> findNumbersCommands;

  const OnDeviceOcr({
    required this.child,
    super.key,
    required this.findNumbersCommands,
  });

  @override
  State<OnDeviceOcr> createState() => _OnDeviceOcrState();
}

class _OnDeviceOcrState extends State<OnDeviceOcr> {
  late final StreamSubscription<FindNumbersCommand> _findNumbersCommands;

  @override
  void initState() {
    super.initState();
    _findNumbersCommands = widget.findNumbersCommands.listen(_onFindNumbers);
  }

  @override
  void dispose() {
    _findNumbersCommands.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onFindNumbers(FindNumbersCommand cmd) async {
    final startedAt = DateTime.now();
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      cmd.completer.completeError(
        StateError('findNumbers: rootIsolateToken == null'),
      );
      return;
    }

    final receivePort = ReceivePort();

    receivePort.listen((message) {
      if (message == _isolateDone) {
        receivePort.close();
        cmd.completer.complete();
        final duration = DateTime.now().difference(startedAt);
        debugPrint('findNumbers: duration=$duration');
        return;
      }

      if (!cmd.completer.isCompleted) {
        Map<String, dynamic> json = jsonDecode(message);
        cmd.sink.add(OcrNumber.fromJson(json));
      }
    });

    Isolate.spawn(
      _findNumbersIsolateEntryPoint,
      [rootIsolateToken, receivePort.sendPort, cmd.path],
    ).then((_) {}, onError: cmd.completer.completeError);
  }
}

const _isolateDone = 'Isolate: done';

Future<void> _findNumbersIsolateEntryPoint(List<Object> args) async {
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

  await textRecognizer.close();

  sendPort.send(_isolateDone);
}
