import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:rive/rive.dart';
import 'package:snapfinance/assets.dart';

class UploadProgressBar extends StatelessWidget {
  final Stream<double> progress;

  const UploadProgressBar(this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    final bar = StreamBuilder(
      builder: (context, snapshot) => LinearProgressIndicator(
        value: snapshot.data ?? .0,
      ),
      stream: progress,
    );

    return PortalTarget(
      anchor: const Aligned(
        follower: Alignment.center,
        target: Alignment.topRight,
      ),
      portalFollower: _ConfettiAnimation(progress),
      child: bar,
    );
  }
}

class _ConfettiAnimation extends StatefulWidget {
  final Stream<double> progress;

  const _ConfettiAnimation(this.progress);

  @override
  State<_ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<_ConfettiAnimation> {
  final _explosion = OneShotAnimation('Explosion', autoplay: false);
  late final StreamSubscription<double> _progress;

  var shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress.listen(_onProgressData);
  }

  @override
  void dispose() {
    _progress.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
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
  }

  void _onProgressData(double value) {
    if (value == .0) {
      // reset animation on new progress (zero value)
      shouldAnimate = true;
    }
    if (value >= 1.0 && shouldAnimate) {
      _explosion.isActive = true;
      shouldAnimate = false;
    }
  }
}
