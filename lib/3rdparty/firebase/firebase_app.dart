import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_auth.dart';
import 'package:snapfinance/firebase_options.dart';

var initializedFirebase = false;

Future<void> runFirebaseApp(Widget app) async {
  if (!initializedFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
        fatal: true,
      );
    }).sendPort);

    initializedFirebase = true;
  }

  runApp(FirebaseAuthApp(child: app));
}
