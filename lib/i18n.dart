final i18n = _Root();

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

  String get again => 'Again';

  String get ok => 'OK';
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
