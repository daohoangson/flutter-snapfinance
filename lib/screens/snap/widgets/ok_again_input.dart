import 'package:flutter/material.dart';
import 'package:snapfinance/i18n.dart';
import 'package:snapfinance/screens/snap/widgets/bottom_sheet_height.dart';

class OkAgainInput extends StatelessWidget {
  final VoidCallback onAgain;
  final VoidCallback? onOk;

  const OkAgainInput({
    required this.onAgain,
    this.onOk,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheetHeightBox(
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
                    i18n.screens.snap.ok,
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
                i18n.screens.snap.again,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
