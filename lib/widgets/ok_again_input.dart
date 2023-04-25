import 'package:flutter/material.dart';
import 'package:snapfinance/widgets/keyboard_height.dart';

class OkAgainInput extends StatelessWidget {
  final VoidCallback onAgain;
  final VoidCallback onOk;

  const OkAgainInput({
    required this.onAgain,
    required this.onOk,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final height = calculateKeyboardHeight(context);
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, bc) {
                final value = bc.maxHeight / 4;
                return ElevatedButton(
                  onPressed: onOk,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(value),
                    shape: const CircleBorder(),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: value),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: TextButton(
              onPressed: onAgain,
              child: Text(
                'Again',
                style: TextStyle(
                  color: theme.hintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
