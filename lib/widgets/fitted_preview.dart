import 'package:flutter/material.dart';

class FittedPreview extends StatelessWidget {
  final Widget child;

  const FittedPreview({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bc) {
        return SizedBox(
          height: bc.maxHeight,
          width: bc.maxWidth,
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: bc.maxWidth * 16 / 9,
              width: bc.maxWidth,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
