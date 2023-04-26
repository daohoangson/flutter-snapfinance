import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';
import 'package:snapfinance/screens/snap/widgets/bottom_sheet_height.dart';

class VndInput extends StatefulWidget {
  final double keyboardHeight;
  final Function(int) onDone;
  final Widget Function(VndEditingController) vndBuilder;

  const VndInput({
    required this.keyboardHeight,
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
          height: widget.keyboardHeight,
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
