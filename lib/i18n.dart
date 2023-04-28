import 'dart:math';

import 'package:flutter/foundation.dart';

final i18n = _Root();

@visibleForTesting
int? debugRandomSeed;

class _Root {
  _Root();

  final screens = const _Screens();

  final thirdParty = const _ThirdParty();

  final widgets = const _Widgets();
}

class _Screens {
  const _Screens();

  final snap = const _ScreensSnap();
}

class _ScreensSnap {
  const _ScreensSnap();

  String get addingTransactionRandomized {
    const options = <String>[
      'Almost done...',
      'Hang in there...',
      'Saving...',
    ];
    final random = Random(debugRandomSeed).nextInt(options.length);
    return options[random];
  }

  String get again => 'Again';

  String get done => 'Done';

  String get save => 'Save';

  String get tapNumber => 'Tap a number 👆';

  String get tapNumberNada => 'No numbers? 😢';
}

class _ThirdParty {
  const _ThirdParty();

  final vnd = const _ThirdPartyVnd();
}

class _ThirdPartyVnd {
  const _ThirdPartyVnd();

  String get continue_ => 'Continue';

  String get takePhoto => 'Take photo';
}

class _Widgets {
  const _Widgets();

  final userIcon = const _WidgetsUserIcon();
}

class _WidgetsUserIcon {
  const _WidgetsUserIcon();

  String get helloAnonymous => 'Hello anonymous';

  String helloX(String name) => 'Hello $name';

  String get signInAnonymouslyQuestionMark => 'Sign in anonymously?';

  String get signInAnonymouslyYes => 'YES!';

  String get signOut => 'SIGN OUT';
}
