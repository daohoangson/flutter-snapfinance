import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:snapfinance/widgets/keyboard_height.dart';

class VndInput extends StatefulWidget {
  final Function(int) onDone;
  final Widget Function(VndEditingController) vndBuilder;

  const VndInput({
    super.key,
    required this.onDone,
    required this.vndBuilder,
  });

  @override
  State<VndInput> createState() => _VndInputState();
}

class _VndInputState extends State<VndInput> {
  var vndEditingController = VndEditingController();

  @override
  void dispose() {
    vndEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.vndBuilder(vndEditingController),
        VndKeyboard(
          height: calculateKeyboardHeight(context),
          labelSize: calculateKeyboardLabelSize(context),
          onTap: (key) {
            vndEditingController.onTap(key);

            if (key.type == KeyboardKeyType.done) {
              final vnd = vndEditingController.vnd;
              vndEditingController.dispose();
              vndEditingController = VndEditingController();

              widget.onDone(vnd);
            }
          },
        ),
      ],
    );
  }
}
