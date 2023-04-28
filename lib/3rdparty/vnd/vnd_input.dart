import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:snapfinance/3rdparty/vnd/vnd_preview.dart';
import 'package:snapfinance/i18n.dart';
import 'package:snapfinance/screens/snap/widgets/bottom_sheet_panel.dart';

class VndInput extends StatefulWidget {
  final double keyboardHeight;
  final Function(int) onDone;

  const VndInput({
    required this.keyboardHeight,
    super.key,
    required this.onDone,
  });

  @override
  State<VndInput> createState() => _VndInputState();
}

class _VndInputState extends State<VndInput> {
  final vndEditingController = VndEditingController();

  @override
  void dispose() {
    vndEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VndPreview(vndEditingController),
        VndKeyboard(
          height: widget.keyboardHeight,
          keyDone: _KeyDone(vndEditingController),
          labelSize: calculateKeyboardLabelSize(context),
          onTap: (key) {
            vndEditingController.onTap(key);

            if (key.type == KeyboardKeyType.done) {
              widget.onDone(vndEditingController.vnd);
            }
          },
        ),
      ],
    );
  }
}

class _KeyDone extends StatelessWidget {
  final VndEditingController controller;

  const _KeyDone(this.controller);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    final phrases = i18n.thirdParty.vnd;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final hasValue = controller.vnd > 0;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation.drive(Tween(begin: .5, end: 1.0)),
              child: child,
            );
          },
          child: hasValue
              ? Icon(
                  Icons.arrow_forward,
                  color: color,
                  key: ValueKey(hasValue),
                  semanticLabel: phrases.continue_,
                )
              : Icon(
                  Icons.camera_alt,
                  color: color,
                  key: ValueKey(hasValue),
                  semanticLabel: phrases.takePhoto,
                ),
        );
      },
    );
  }
}
