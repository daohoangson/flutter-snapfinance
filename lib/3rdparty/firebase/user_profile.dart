import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends Equatable {
  final String? id;
  final bool? isAnonymous;

  UserProfile.from(User? firebase)
      : id = firebase?.uid,
        isAnonymous = firebase?.isAnonymous;

  @override
  List<Object?> get props => [
        id,
        isAnonymous,
      ];

  FirebaseAuth get _firebase => FirebaseAuth.instance;

  Future<void> signOut() => _firebase.signOut();

  Future<void> signInAnonymously() => _firebase.signInAnonymously();

  Widget inheritedWidget(Widget child) =>
      _UserProfileInheritedWidget(value: this, child: child);

  static UserProfile? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_UserProfileInheritedWidget>()
      ?.value;
}

class _UserProfileInheritedWidget extends InheritedWidget {
  final UserProfile? value;

  const _UserProfileInheritedWidget({
    required super.child,
    required this.value,
  });

  @override
  bool updateShouldNotify(covariant _UserProfileInheritedWidget oldWidget) {
    return value != oldWidget.value;
  }
}
