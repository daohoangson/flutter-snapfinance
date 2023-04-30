import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/widgets/image_viewer.dart';

void main() async {
  debugCheckIntrinsicSizes = true;
  debugUseAssetImage = true;

  final testCases = <String, String>{
    'android_up':
        '{"cornerPoints":[[1424,583],[1414,266],[1479,264],[1488,580]],"text":"1047340"}',
    'android_left':
        '{"cornerPoints":[[2201,655],[2475,650],[2476,710],[2201,714]],"text":"1047340"}',
    'android_right':
        '{"cornerPoints":[[1234,1687],[985,1700],[982,1653],[1231,1640]],"text":"1047340"}',
    'iphone_up':
        '{"cornerPoints":[[1517,921],[1496,554],[1567,550],[1587,916]],"text":"1047340"}',
    'iphone_left':
        '{"cornerPoints":[[2493,1028],[2806,1013],[2809,1076],[2495,1090]],"text":"1047340"}',
    'iphone_right':
        '{"cornerPoints":[[1518,2061],[1220,2070],[1218,2011],[1516,2002]],"text":"1047340"}',
  };

  for (final name in testCases.keys) {
    testGoldens(name, _testCases(name, testCases[name]!));
  }
}

Future<void> Function(WidgetTester) _testCases(
  String name,
  String numberJson,
) {
  return (tester) async {
    await tester.pumpWidgetBuilder(
      ImageViewer(
        numbers: [
          OcrNumber.fromJson(jsonDecode(numberJson)),
        ],
        path: 'assets/placeholders/$name.jpg',
        onNumberPressed: (_) {},
      ),
      surfaceSize: const Size(1000, 1000),
    );

    await tester.runAsync(() async {
      final imageViewers = find.byType(ImageViewer).evaluate();
      for (final imageViewer in imageViewers) {
        final imageViewerState =
            ((imageViewer as StatefulElement).state as ImageViewerState);
        while (imageViewerState.imageSize == null) {
          await Future.delayed(const Duration(milliseconds: 10));
        }
      }
    });

    await screenMatchesGolden(tester, name);
  };
}
