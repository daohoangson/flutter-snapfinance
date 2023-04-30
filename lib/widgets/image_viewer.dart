import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/widgets/loading.dart';
import 'package:snapfinance/widgets/nope.dart';
import 'package:snapfinance/widgets/test_indicator.dart';

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

abstract class ImageViewerState extends State<ImageViewer> {
  @visibleForTesting
  Size? get imageSize;
}

class _ImageViewerState extends State<ImageViewer> implements ImageViewerState {
  late final ImageProvider _imageProvider;
  late final ImageStreamListener _imageStreamListener;

  ImageStream? _imageStream;

  @override
  Size? get imageSize => _imageSize;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();

    if (debugUseAssetImage) {
      _imageProvider = AssetImage(widget.path);
    } else {
      _imageProvider = FileImage(File(widget.path));
    }

    _imageStreamListener = ImageStreamListener(
      (info, _) {
        _imageStream?.removeListener(_imageStreamListener);

        final image = info.image;
        final imageSize = Size(image.width.toDouble(), image.height.toDouble());
        image.dispose();

        _setImageSize(imageSize);
      },
      onError: (error, _) {
        logger.error('Could not resolve ${widget.path}', error);
        _setImageSize(Size.zero);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_imageStream == null) {
      _imageStream =
          _imageProvider.resolve(createLocalImageConfiguration(context));
      _imageStream?.addListener(_imageStreamListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = _imageSize;
    if (imageSize == null) {
      return loading;
    }
    if (imageSize == Size.zero) {
      return nope;
    }

    final imageProvider = _imageProvider;
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
          final renderOffset = Offset(
            (boxWidth - renderWidth) / 2,
            (boxHeight - renderHeight) / 2,
          );
          final renderSize = Size(renderWidth, renderHeight);

          final onPressed = widget.onNumberPressed;

          return Stack(
            children: [
              Positioned.fill(
                child: Image(
                  fit: BoxFit.cover,
                  image: imageProvider,
                ),
              ),
              if (imageProvider is AssetImage)
                Positioned.fill(
                  child: TestIndicator(
                    animate: false,
                    text: imageProvider.assetName,
                  ),
                ),
              ...widget.numbers.map((number) => _buildPositioned(
                    imageSize: imageSize,
                    number: number,
                    renderOffset: renderOffset,
                    renderSize: renderSize,
                    child: Animate(
                      effects: const [
                        ScaleEffect(),
                      ],
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
                  )),
            ],
          );
        },
      ),
    );
  }

  Positioned _buildPositioned({
    required Widget child,
    required Size imageSize,
    required OcrNumber number,
    required Offset renderOffset,
    required Size renderSize,
  }) {
    final p0 = number.cornerPoints[0];
    final p2 = number.cornerPoints[2];

    // the first corner point is the top left one visually
    // we have to compensate for exif orientation
    final isFlippedHorizontally = p2.x < p0.x;
    final isFlippedVertically = p2.y < p0.y;
    Point<num> topLeft;
    if (isFlippedHorizontally && isFlippedVertically) {
      // rotated 180°
      topLeft = Point(imageSize.width - p0.x, imageSize.height - p0.y);
    } else if (isFlippedHorizontally) {
      // rotated 90° clockwise
      topLeft = Point(p0.y, imageSize.height - p0.x);
    } else if (isFlippedVertically) {
      // rotated 90° counter clockwise
      topLeft = Point(imageSize.width - p0.y, p0.x);
    } else {
      topLeft = p0;
    }

    return Positioned(
      top: (topLeft.y / imageSize.height) * renderSize.height + renderOffset.dy,
      left: (topLeft.x / imageSize.width) * renderSize.width + renderOffset.dx,
      child: child,
    );
  }

  void _setImageSize(Size imageSize) {
    _imageSize = imageSize;
    if (mounted) {
      setState(() {});
    }
  }
}
