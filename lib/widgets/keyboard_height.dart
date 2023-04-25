import 'dart:math';

import 'package:flutter/material.dart';

double calculateKeyboardHeight(BuildContext context) {
  return calculateKeyboardLabelSize(context) * 10;
}

double calculateKeyboardLabelSize(BuildContext context) {
  final fontSize = DefaultTextStyle.of(context).style.fontSize ?? 14.0;
  return min(fontSize * 1.5, 30.0);
}
