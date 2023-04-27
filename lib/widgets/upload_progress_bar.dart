import 'package:flutter/material.dart';

class UploadProgressBar extends StatelessWidget {
  final Stream<double> progress;

  const UploadProgressBar(this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) => LinearProgressIndicator(
        value: snapshot.data ?? .0,
      ),
      stream: progress,
    );
  }
}
