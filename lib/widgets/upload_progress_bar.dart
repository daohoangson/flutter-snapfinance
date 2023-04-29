import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:rive/rive.dart';
import 'package:snapfinance/assets.dart';

@visibleForTesting
var debugRenderColoredBox = false;

class UploadProgressBar extends StatelessWidget {
  final double initialData;
  final Stream<double> stream;

  const UploadProgressBar({
    super.key,
    required this.initialData,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    final bar = StreamBuilder(
      builder: (context, snapshot) => LinearProgressIndicator(
        value: snapshot.requireData,
      ),
      initialData: initialData,
      stream: stream,
    );

    return PortalTarget(
      anchor: const Aligned(
        follower: Alignment.center,
        target: Alignment.topRight,
      ),
      portalFollower: _ConfettiAnimation(stream),
      child: bar,
    );
  }
}

class _ConfettiAnimation extends StatefulWidget {
  final Stream<double> stream;

  const _ConfettiAnimation(this.stream);

  @override
  State<_ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<_ConfettiAnimation> {
  late final OneShotAnimation _explosion;
  late final StreamSubscription<double> _subscription;

  var _activateCount = 0;
  var _shouldAnimate = false;
  var _stopCount = 0;

  @override
  void initState() {
    super.initState();

    _explosion = OneShotAnimation(
      'Explosion',
      autoplay: true,
      onStop: () => setState(() => _stopCount++),
    );

    _subscription = widget.stream.listen(_onData);
  }

  @override
  void dispose() {
    _explosion.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget built = Opacity(
      // the animation has a weird initial artifact
      // https://github.com/daohoangson/flutter-snapfinance/blob/c69e57c7260314312beb11a763fa401a14b5c2ab/test/screens/snap/goldens/find_numbers.png
      // so we have to auto play it once to clean up
      // the first activation will be near invisible
      // (zero opacity doesn't work so we are using a very low value)
      opacity: _stopCount == 0 ? .01 : 1,
      child: RiveAnimation.asset(
        assets.animations.confetti,
        controllers: [_explosion],
        fit: BoxFit.contain,
        onInit: (artboard) {
          for (final fill in [...artboard.fills]) {
            // the design has some background so we have to remove it
            artboard.removeFill(fill);
          }
        },
      ),
    );

    if (debugRenderColoredBox) {
      built = ColoredBox(
        color: _activateCount == 0
            ? Colors.transparent
            : (_activateCount == 1
                ? const Color(0x11FF0000) // red
                : const Color(0x1100FF00) // green
            ),
        child: built,
      );
    }

    return IgnorePointer(
      child: built,
    );
  }

  void _onData(double value) {
    if (value == .0) {
      // reset animation on new progress (zero value)
      _shouldAnimate = true;
    }
    if (value >= 1.0 && _shouldAnimate) {
      _explosion.isActive = true;
      _activateCount++;
      _shouldAnimate = false;
    }
  }
}
