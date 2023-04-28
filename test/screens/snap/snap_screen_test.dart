import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snapfinance/3rdparty/camera/camera_preview.dart'
    as camera_preview;
import 'package:snapfinance/3rdparty/camera/fake_camera_preview.dart'
    as fake_camera_preview;
import 'package:snapfinance/3rdparty/camera/take_photo_command.dart';
import 'package:snapfinance/3rdparty/firebase/db/add_transaction_command.dart';
import 'package:snapfinance/3rdparty/firebase/storage/upload_file_command.dart';
import 'package:snapfinance/3rdparty/ml/find_numbers_command.dart';
import 'package:snapfinance/3rdparty/ml/ocr_number.dart';
import 'package:snapfinance/i18n.dart' as i18n;
import 'package:snapfinance/screens/snap/snap_controller.dart';
import 'package:snapfinance/screens/snap/snap_screen.dart';
import 'package:snapfinance/screens/snap/snap_services.dart';
import 'package:snapfinance/screens/snap/snap_state.dart';
import 'package:snapfinance/widgets/image_viewer.dart' as image_viewer;
import 'package:synchronized/synchronized.dart';

void main() async {
  debugCheckIntrinsicSizes = true;
  camera_preview.debugIsDeviceOverride = false;
  fake_camera_preview.debugRandomSeed = 1;
  fake_camera_preview.debugTriggerOnInitialized = false;
  image_viewer.debugUseAssetImage = true;
  i18n.debugRandomSeed = 1;

  setUpAll(() {
    registerFallbackValue(AddTransactionCommand(vnd: 0));
    registerFallbackValue(FindNumbersCommand('', null));
    registerFallbackValue(TakePhotoCommand());
    registerFallbackValue(UploadFileCommand('', null));
  });

  final testCases = <String, List<_TestStep>>{
    'happy_path': [
      _TestStep(
        'initializing: tap 5',
        (s) async {
          final key5 = s.descendant(find.bySemanticsLabel('5'));
          await s.tester.tap(key5);
        },
      ),
      _TestStep(
        'initialized',
        (s) => s.move((v) => v.initiating.initialized()),
      ),
      _TestStep(
        'tap 0 twice',
        (s) async {
          final key0 = s.descendant(find.bySemanticsLabel('0'));
          await s.tester.tap(key0);
          await s.tester.tap(key0);
        },
      ),
      _TestStep(
        'tap continue -> taking photo',
        (s) async {
          when(() => s.services.takePhoto(any())).thenAnswer((invocation) {
            _takePhotoCommands[s] = invocation.positionalArguments[0];
          });

          final keyDone = s.descendant(find.bySemanticsLabel(_labelContinue));
          await s.tester.tap(keyDone);
        },
      ),
      _TestStep(
        'took photo -> uploading',
        (s) {
          when(() => s.services.uploadFile(any())).thenAnswer((invocation) {
            _uploadFileCommands[s] = invocation.positionalArguments[0];
          });

          _takePhotoCommands[s]
              ?.completer
              .complete(fake_camera_preview.assetNameMidjourney);
        },
      ),
      _TestStep(
        'upload 50%',
        (s) => _uploadFileCommands[s]?.progress?.add(.5),
      ),
      _TestStep(
        'upload 100%',
        (s) => _uploadFileCommands[s]?.progress?.add(1),
      ),
      _TestStep(
        'tap save',
        (s) {
          when(() => s.services.addTransaction(any())).thenAnswer((invocation) {
            _addTransactionCommands[s] = invocation.positionalArguments[0];
          });

          s.move((v) => v.reviewing.confirm());
        },
      ),
      _TestStep(
        'added transaction -> the end',
        (s) => _addTransactionCommands[s]?.completer.complete('foo'),
      ),
    ],
    'find_numbers': [
      _TestStep(
        'initialized',
        (s) => s.move((v) => v.initiating.initialized()),
      ),
      _TestStep(
        'tap camera -> taking photo',
        (s) async {
          when(() => s.services.takePhoto(any())).thenAnswer((invocation) {
            _takePhotoCommands[s] = invocation.positionalArguments[0];
          });

          final keyDone = s.descendant(find.bySemanticsLabel(_labelTakePhoto));
          await s.tester.tap(keyDone);
        },
      ),
      _TestStep(
        'took photo -> processing',
        (s) {
          when(() => s.services.findNumbers(any())).thenAnswer((invocation) {
            _findNumbersCommands[s] = invocation.positionalArguments[0];
          });

          _takePhotoCommands[s]
              ?.completer
              .complete(fake_camera_preview.assetNameMidjourney);
        },
      ),
      _TestStep(
        'found 50k',
        (s) => _findNumbersCommands[s]?.numbers?.add(OcrNumber.fromJson(jsonDecode(
            '{"text":"50000","cornerPoints":[[350,350],[450,350],[450,450],[350,450]]}'))),
      ),
      _TestStep(
        'found 100k',
        (s) => _findNumbersCommands[s]?.numbers?.add(OcrNumber.fromJson(jsonDecode(
            '{"text":"100000","cornerPoints":[[250,250],[350,250],[350,350],[250,350]]}'))),
      ),
      _TestStep(
        'completed processing',
        (s) => _findNumbersCommands[s]?.completer.complete(),
      ),
      _TestStep(
        'tap 100k',
        (s) => s.move((v) => v.reviewing.tapVnd(100000)),
      ),
      _TestStep(
        'tap save',
        (s) {
          when(() => s.services.addTransaction(any())).thenAnswer((invocation) {
            _addTransactionCommands[s] = invocation.positionalArguments[0];
          });

          s.move((v) => v.reviewing.confirm());
        },
      ),
      _TestStep(
        'added transaction -> the end',
        (s) => _addTransactionCommands[s]?.completer.complete('foo'),
      ),
    ],
  };

  for (final name in testCases.keys) {
    testGoldens(name, _testCases(name, testCases[name]!));
  }
}

final _addTransactionCommands = Expando<AddTransactionCommand>();
final _findNumbersCommands = Expando<FindNumbersCommand>();
final _takePhotoCommands = Expando<TakePhotoCommand>();
final _uploadFileCommands = Expando<UploadFileCommand>();

final _labelContinue = RegExp(i18n.i18n.thirdParty.vnd.continue_);
final _labelTakePhoto = RegExp(i18n.i18n.thirdParty.vnd.takePhoto);

void _addScenarios(
  WidgetTester tester,
  GoldenBuilder builder,
  Lock lock,
  List<_TestStep> steps,
) {
  for (var i = 0; i < steps.length; i++) {
    final step = steps[i];
    builder.addScenario(
      step.name,
      _SnapScreenTester(tester, lock, steps.take(i + 1)),
    );
  }
}

Future<void> Function(WidgetTester) _testCases(
  String name,
  List<_TestStep> steps,
) {
  return (tester) async {
    const widthToHeightRatio = .4;
    final columns = steps.length;
    final surfaceWidth = columns * 320.0;

    final builder = GoldenBuilder.grid(
      columns: columns,
      widthToHeightRatio: widthToHeightRatio,
      wrap: (child) => AspectRatio(
        aspectRatio: widthToHeightRatio + .1,
        child: Portal(
          child: child,
        ),
      ),
    );

    final lock = Lock();
    _addScenarios(tester, builder, lock, steps);

    final surfaceHeight = surfaceWidth / columns / widthToHeightRatio;
    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: Size(surfaceWidth, surfaceHeight),
    );
    await screenMatchesGolden(tester, name);
  };
}

class _MockServices extends Mock implements SnapServices {}

class _SnapScreenTester extends StatefulWidget {
  final WidgetTester tester;
  final Lock lock;
  final Iterable<_TestStep> steps;

  const _SnapScreenTester(this.tester, this.lock, this.steps);

  @override
  State<_SnapScreenTester> createState() => _SnapScreenTesterState();
}

class _SnapScreenTesterState extends State<_SnapScreenTester> {
  late final SnapController controller;
  final services = _MockServices();

  WidgetTester get tester => widget.tester;

  @override
  void initState() {
    super.initState();
    controller = SnapController(services);

    final steps = [...widget.steps];
    late Function fn;
    fn = () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.lock.synchronized(() async {
          final step = steps.removeAt(0);
          await Future.value(step.fn(this));
        });

        if (steps.isNotEmpty) {
          fn();
        }
      });
    };
    fn();
  }

  @override
  Widget build(BuildContext context) {
    return SnapScreenInner(controller, services);
  }

  Finder descendant(Finder matching) {
    return find.descendant(
      of: find.byWidget(widget),
      matching: matching,
    );
  }

  void move(SnapState Function(SnapState) fn) {
    final previous = controller.value;
    final next = fn(previous);
    controller.move(previous, next);
  }
}

extension _SnapState on SnapState {
  StateInitiatingCamera get initiating => this as StateInitiatingCamera;
  StateReviewing get reviewing => this as StateReviewing;
}

class _TestStep {
  final String name;

  final Function(_SnapScreenTesterState) fn;

  _TestStep(this.name, this.fn);
}
