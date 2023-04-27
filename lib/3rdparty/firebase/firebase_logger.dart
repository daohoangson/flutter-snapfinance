import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_app.dart';

const logger = Logger();

class Logger {
  const Logger();

  FirebaseCrashlytics get _firebase => FirebaseCrashlytics.instance;

  void debug(String message) {
    if (initializedFirebase) {
      _firebase.log(message);
    }

    debugPrint(message);
  }

  void error(String message, dynamic error) {
    if (initializedFirebase) {
      _firebase.recordError(error, null, reason: message);
    }

    debugPrint(message);

    // ignore: avoid_print
    print(error);
  }

  void verbose(String message) {
    debugPrint(message);
  }
}
