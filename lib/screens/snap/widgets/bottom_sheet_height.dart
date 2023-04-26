import 'dart:math';

import 'package:flutter/material.dart';

double calculateBottomSheetHeight(BuildContext context) {
  return calculateKeyboardLabelSize(context) * 10;
}

double calculateKeyboardLabelSize(BuildContext context) {
  final fontSize = DefaultTextStyle.of(context).style.fontSize ?? 14.0;
  return min(fontSize * 1.5, 30.0);
}

class BottomSheetHeightBox extends StatelessWidget {
  final Widget child;

  const BottomSheetHeightBox({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: calculateBottomSheetHeight(context),
      child: child,
    );
  }
}
