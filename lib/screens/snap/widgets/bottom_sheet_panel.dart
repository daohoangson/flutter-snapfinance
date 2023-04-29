import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snapfinance/3rdparty/vnd/vnd_preview.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';

double calculateBottomSheetHeight(BuildContext context) {
  return calculateKeyboardLabelSize(context) * 10;
}

double calculateKeyboardLabelSize(BuildContext context) {
  final fontSize = DefaultTextStyle.of(context).style.fontSize ?? 14.0;
  return min(fontSize * 1.5, 30.0);
}

class BottomSheetPanel extends StatelessWidget {
  final Widget child;
  final Step1? value;

  const BottomSheetPanel({
    required this.child,
    super.key,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VndPreview.vnd(value?.vnd ?? 0),
        Animate(
          effects: const [
            SlideEffect(
              duration: Duration(milliseconds: 100),
              begin: Offset(.5, .0),
              end: Offset.zero,
            ),
          ],
          child: SizedBox(
            height: calculateBottomSheetHeight(context),
            child: child,
          ),
        ),
      ],
    );
  }
}
