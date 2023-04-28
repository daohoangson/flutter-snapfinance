import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/vnd/vnd_input.dart';
import 'package:snapfinance/i18n.dart';
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';
import 'package:snapfinance/screens/snap/widgets/bottom_sheet_panel.dart';
import 'package:snapfinance/screens/snap/widgets/two_buttons.dart';

class SnapBottomSheet extends StatelessWidget {
  final SnapController controller;

  const SnapBottomSheet(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final phrases = i18n.screens.snap;

    return StreamBuilder(
      builder: (context, snapshot) => snapshot.requireData.map(
        onFailure: _onFailure,
        onInitiatingCamera: (_) => VndInput(
          keyboardHeight: calculateBottomSheetHeight(context),
          onDone: (vnd) => controller.move(_, _.setVnd(vnd)),
        ),
        onInitializedCamera: (_) => VndInput(
          keyboardHeight: calculateBottomSheetHeight(context),
          onDone: (vnd) => controller.move(_, _.takePhoto(vnd)),
        ),
        onTakingPhoto: (_) => VndInput(
          keyboardHeight: calculateBottomSheetHeight(context),
          onDone: (vnd) => controller.move(_, _.setVnd(vnd)),
        ),
        onProcessingPhoto: _onProcessingPhotoOrReviewing,
        onReviewing: _onProcessingPhotoOrReviewing,
        onAddingTransaction: (adding) => TwoButtons(
          positiveText: phrases.addingTransactionRandomized,
          value: adding,
        ),
        onAddedTransaction: (added) => TwoButtons(
          positiveOnPressed: () => controller.move(added, added.reset()),
          positiveText: phrases.done,
          value: added,
        ),
      ),
      initialData: controller.value,
      stream: controller.stream,
    );
  }

  Widget _onFailure(StateFailure failure) {
    final previous = failure.previous;
    return Builder(
      builder: (context) {
        return BottomSheetPanel(
          value: previous is Step1 ? previous : null,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                failure.error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _onProcessingPhotoOrReviewing(Step2 value) {
    final phrases = i18n.screens.snap;
    final reviewing = value is StateReviewing ? value : null;
    final canContinue = reviewing?.canContinue ?? false;

    return TwoButtons(
      negativeOnPressed: () => controller.move(value, value.reset()),
      negativeText: phrases.again,
      positiveOnPressed: canContinue && reviewing != null
          ? () => controller.move(reviewing, reviewing.confirm())
          : null,
      positiveText: canContinue
          ? phrases.save
          : (controller.foundNumbers.isNotEmpty
              ? phrases.tapNumber
              : phrases.tapNumberNada),
      value: value,
    );
  }
}
