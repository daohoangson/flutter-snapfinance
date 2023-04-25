import 'dart:math';

import 'package:intl/intl.dart';

final decimalPattern = NumberFormat.decimalPattern('vi_VN');

class OcrNumber {
  final int value;
  final List<Point<int>> cornerPoints;

  OcrNumber(this.value, this.cornerPoints);

  factory OcrNumber.fromJson(Map<String, dynamic> json) => OcrNumber(
        decimalPattern.parse(json['text']).toInt(),
        (json['cornerPoints'] as List)
            .map<Point<int>>((p) => Point<int>(p[0], p[1]))
            .toList(growable: false),
      );
}
