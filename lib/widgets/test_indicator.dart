import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TestIndicator extends StatelessWidget {
  final bool animate;
  final String text;

  const TestIndicator({
    required this.animate,
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, bc) {
          Widget built = Text(
            text,
            style: Theme.of(context).textTheme.headlineLarge,
          );

          if (animate) {
            built = Animate(
              effects: const [
                ShimmerEffect(),
              ],
              onComplete: (controller) => controller.repeat(reverse: true),
              child: built,
            );
          }

          return built;
        },
      ),
    );
  }
}
