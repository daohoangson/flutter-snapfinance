import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snapfinance/features/ml/ocr_number.dart';
import 'package:snapfinance/widgets/loading.dart';

class ImageViewer extends StatefulWidget {
  final Stream<OcrNumber> numbers;
  final Function(int) onVnd;
  final String path;

  const ImageViewer({
    super.key,
    required this.numbers,
    required this.onVnd,
    required this.path,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final numbers = <OcrNumber>[];

  late ImageProvider imageProvider;
  late StreamSubscription<OcrNumber> numbersSubscription;

  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    imageProvider = FileImage(File(widget.path));
    numbersSubscription = widget.numbers.listen(_onNumber);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageProvider.resolve(createLocalImageConfiguration(context)).addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            final image = info.image;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });
        }
      }),
    );
  }

  @override
  void didUpdateWidget(covariant ImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.numbers != oldWidget.numbers) {
      numbersSubscription.cancel();
      numbersSubscription = widget.numbers.listen(_onNumber);
    }
  }

  @override
  void dispose() {
    numbersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = _imageSize;

    if (imageSize == null) {
      return loading;
    }

    return AspectRatio(
      aspectRatio: imageSize.width / imageSize.height,
      child: LayoutBuilder(
        builder: (context, bc) {
          final width = bc.maxWidth;
          final height = bc.maxHeight;

          return Stack(
            children: [
              Image(image: imageProvider),
              ...numbers.map(
                (number) {
                  final topLeft = number.cornerPoints[0];
                  // TODO: verify these coordinates work in both Android & iOS
                  final top = (topLeft.x / imageSize.height) * height;
                  final left = (1 - topLeft.y / imageSize.width) * width;
                  return Positioned(
                    top: top,
                    left: left,
                    child: Opacity(
                      opacity: .5,
                      child: ElevatedButton(
                        onPressed: () => widget.onVnd(number.value),
                        child: Text(number.value.toString()),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _onNumber(OcrNumber number) {
    const min5k = 5000;
    const max50mil = 50000000;
    if (number.value < min5k || number.value > max50mil) {
      return;
    }

    for (final existing in numbers) {
      if (number.value == existing.value) {
        return;
      }
    }

    setState(() => numbers.add(number));
  }
}
