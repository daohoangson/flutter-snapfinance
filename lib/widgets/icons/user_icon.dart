import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/firebase/user_profile.dart';
import 'package:snapfinance/i18n.dart';

class UserIcon extends StatefulWidget {
  const UserIcon({super.key});

  @override
  State<UserIcon> createState() => _UserIconState();
}

class _UserIconState extends State<UserIcon> {
  @override
  Widget build(BuildContext context) {
    final phrases = i18n.widgets.userIcon;
    final userProfile = UserProfile.of(context);
    final isAnonymous = userProfile?.isAnonymous == true;
    final userId = userProfile?.id;
    if (userId == null) {
      return IconButton(
        icon: const Text('🫥'),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(phrases.signInAnonymouslyQuestionMark),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await userProfile?.signInAnonymously();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(phrases.signInAnonymouslyYes),
              ),
            ],
          ),
        ),
      );
    }

    return IconButton(
      icon: Text(isAnonymous ? '😎' : '😇'),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            isAnonymous ? phrases.helloAnonymous : phrases.helloX(userId),
          ),
          content: Text(userId),
          actions: [
            TextButton(
              onPressed: () async {
                await userProfile?.signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(phrases.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
