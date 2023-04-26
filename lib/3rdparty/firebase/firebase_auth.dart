import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_logger.dart';
import 'package:snapfinance/3rdparty/firebase/user_profile.dart';

class FirebaseAuthApp extends StatefulWidget {
  final Widget child;

  const FirebaseAuthApp({required this.child, super.key});

  @override
  State<FirebaseAuthApp> createState() => _FirebaseAuthAppState();
}

class _FirebaseAuthAppState extends State<FirebaseAuthApp> {
  late final User? initialFirebaseUser;

  FirebaseAuth get _firebase => FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    initialFirebaseUser = _firebase.currentUser;
    if (initialFirebaseUser == null) {
      _firebase.signInAnonymously().then(
            (_) => logger.debug('Signed in anonymously!'),
            onError: (error) => logger.error('signInAnonymously', error),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) =>
          UserProfile.from(snapshot.data).inheritedWidget(widget.child),
      initialData: initialFirebaseUser,
      stream: _firebase.userChanges(),
    );
  }
}
