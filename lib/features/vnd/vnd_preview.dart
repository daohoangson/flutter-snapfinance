import 'package:flutter/material.dart';
import 'package:flutter_vnd_keyboard/flutter_vnd_keyboard.dart';

class VndPreview extends StatelessWidget {
  final VndEditingController controller;

  const VndPreview(this.controller, {super.key});

  factory VndPreview.vnd(int vnd) => VndPreview(VndEditingController(vnd: vnd));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: EditableVnd(
        controller: controller,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
