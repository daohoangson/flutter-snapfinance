import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class VndPreview extends StatelessWidget {
  final bool autofocus;
  final VndEditingController controller;
  final bool enabled;

  const VndPreview(
    this.controller, {
    this.autofocus = true,
    this.enabled = true,
    super.key,
  });

  factory VndPreview.vnd(int vnd) => VndPreview(
        // TODO: fix this leak
        VndEditingController(vnd: vnd),
        autofocus: false,
        enabled: false,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: EditableVnd(
        autofocus: autofocus,
        controller: controller,
        enabled: enabled,
        showCursor: false,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
