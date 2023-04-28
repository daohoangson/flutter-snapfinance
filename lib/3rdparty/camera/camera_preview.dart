import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/camera/camerawesome_preview.dart';
import 'package:snapfinance/3rdparty/camera/fake_camera_preview.dart';
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/widgets/loading.dart';

@visibleForTesting
bool? debugIsDeviceOverride;

class CameraPreview extends StatefulWidget {
  final VoidCallback? onInitialized;
  final Stream<TakePhotoCommand>? takePhotoCommands;

  const CameraPreview({
    super.key,
    this.onInitialized,
    this.takePhotoCommands,
  });

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  final isDevice = ValueNotifier<bool?>(debugIsDeviceOverride);

  @override
  void initState() {
    super.initState();

    if (isDevice.value != null) {
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      deviceInfo.iosInfo.then((_) => isDevice.value = _.isPhysicalDevice);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      deviceInfo.androidInfo.then((_) => isDevice.value = _.isPhysicalDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: isDevice,
      builder: (_, __) {
        if (isDevice.value == null) {
          return loading;
        } else if (isDevice.value == false) {
          return FakeCameraPreview(
            onInitialized: widget.onInitialized,
            takePhotoCommands: widget.takePhotoCommands,
          );
        } else {
          return CameraAwesomePreview(
            onInitialized: widget.onInitialized,
            takePhotoCommands: widget.takePhotoCommands,
          );
        }
      },
    );
  }
}
