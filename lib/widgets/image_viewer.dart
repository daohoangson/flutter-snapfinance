import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/widgets/loading.dart';

class ImageViewer extends StatefulWidget {
  final List<OcrNumber> numbers;
  final Function(int)? onNumberPressed;
  final String path;

  const ImageViewer({
    super.key,
    required this.numbers,
    this.onNumberPressed,
    required this.path,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late final ImageProvider imageProvider;

  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    imageProvider = FileImage(File(widget.path));
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
          final onPressed = widget.onNumberPressed;

          return Stack(
            children: [
              Image(image: imageProvider),
              ...widget.numbers.map(
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
                        onPressed: onPressed != null
                            ? () => onPressed(number.value)
                            : null,
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
}
