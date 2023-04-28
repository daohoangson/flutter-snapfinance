import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/widgets/loading.dart';

@visibleForTesting
var debugUseAssetImage = false;

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

    if (debugUseAssetImage) {
      imageProvider = AssetImage(widget.path);
    } else {
      imageProvider = FileImage(File(widget.path));
    }
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
    final imageRatio = imageSize.width / imageSize.height;

    return AspectRatio(
      aspectRatio: imageSize.width / imageSize.height,
      child: LayoutBuilder(
        builder: (context, bc) {
          final boxWidth = bc.maxWidth;
          final boxHeight = bc.maxHeight;
          final boxRatio = boxWidth / boxHeight;

          final renderWidth =
              boxRatio > imageRatio ? boxWidth : (boxHeight * imageRatio);
          final renderHeight = renderWidth / imageRatio;
          final renderOffsetX = (boxWidth - renderWidth) / 2;
          final renderOffsetY = (boxHeight - renderHeight) / 2;

          final onPressed = widget.onNumberPressed;

          return Stack(
            children: [
              Positioned.fill(
                child: Image(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
              ),
              ...widget.numbers.map(
                (number) {
                  final p0 = number.cornerPoints[0];
                  final p2 = number.cornerPoints[2];
                  // different library detects different orientation so
                  // we have to compenstate here to display the buttons correctly
                  final isRotated = p2.y < p0.y;
                  final topLeft = isRotated ? Point(p0.y, p0.x) : p0;
                  final top = (topLeft.y / imageSize.height) * renderHeight +
                      renderOffsetY;
                  final left0 = topLeft.x / imageSize.width;
                  final left = (isRotated ? (1 - left0) : left0) * renderWidth +
                      renderOffsetX;

                  return Positioned(
                    top: top,
                    left: left,
                    child: Animate(
                      effects: const [ScaleEffect()],
                      child: Opacity(
                        opacity: .5,
                        child: ElevatedButton(
                          onPressed: onPressed != null
                              ? () => onPressed(number.value)
                              : null,
                          child: Text(number.value.toString()),
                        ),
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
