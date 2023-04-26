import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/vnd/vnd_input.dart';
import 'package:snapfinance/3rdparty/vnd/vnd_preview.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';
import 'package:snapfinance/screens/snap/widgets/bottom_sheet_height.dart';
import 'package:snapfinance/screens/snap/widgets/ok_again_input.dart';

class SnapBottomSheet extends StatelessWidget {
  final SnapController controller;

  const SnapBottomSheet(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) => snapshot.requireData.map(
        onFailure: (state) => BottomSheetHeightBox(
          child: Center(
            child: Text(
              state.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        onInitiatingCamera: (_) => VndInput(
          keyboardHeight: calculateBottomSheetHeight(context),
          onDone: (vnd) => controller.move(_, _.setVnd(vnd)),
          vndBuilder: VndPreview.new,
        ),
        onInitializedCamera: (_) => VndInput(
          keyboardHeight: calculateBottomSheetHeight(context),
          onDone: (vnd) => controller.move(_, _.takePhoto(vnd)),
          vndBuilder: VndPreview.new,
        ),
        onTakingPhoto: (_) => VndInput(
          keyboardHeight: calculateBottomSheetHeight(context),
          onDone: (vnd) => controller.move(_, _.setVnd(vnd)),
          vndBuilder: VndPreview.new,
        ),
        onProcessingPhoto: (processing) => _buildOkAgainInput(processing),
        onReviewing: (reviewing) => _buildOkAgainInput(reviewing),
      ),
      initialData: controller.value,
      stream: controller.stream,
    );
  }

  Widget _buildOkAgainInput(Step2 value) {
    return Column(
      children: [
        VndPreview.vnd(value.vnd),
        OkAgainInput(
          onAgain: () => controller.move(value, value.reset()),
          onOk: value is StateReviewing
              ? value.canContinue
                  ? () {}
                  : null
              : null,
        ),
      ],
    );
  }
}
