import 'package:flutter/material.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';
import 'package:snapfinance/screens/snap/widgets/bottom_sheet_panel.dart';

class TwoButtons extends StatelessWidget {
  final VoidCallback? negativeOnPressed;
  final String? negativeText;
  final VoidCallback? positiveOnPressed;
  final String positiveText;
  final Step1 value;

  const TwoButtons({
    this.negativeOnPressed,
    this.negativeText,
    this.positiveOnPressed,
    required this.positiveText,
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheetPanel(
      value: value,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, bc) {
                final fontSize = bc.maxHeight / 4;
                final text = Text(
                  positiveText,
                  style: TextStyle(fontSize: fontSize),
                );
                if (positiveOnPressed == null) {
                  return Center(child: text);
                }

                return ElevatedButton(
                  onPressed: positiveOnPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(fontSize),
                    shape: const CircleBorder(),
                  ),
                  child: text,
                );
              },
            ),
          ),
          Opacity(
            opacity: negativeOnPressed != null ? 1 : 0,
            child: SafeArea(
              top: false,
              child: TextButton(
                onPressed: negativeOnPressed,
                child: Text(
                  negativeText ?? '',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
