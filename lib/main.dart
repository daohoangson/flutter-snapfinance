import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/firebase/firebase_app.dart';
import 'package:snapfinance/screens/snap/snap_screen.dart';
import 'package:snapfinance/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runFirebaseApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeApp(
      builder: (context, theme, darkTheme) {
        return MaterialApp(
          title: 'Snap Finance',

          // colors and theme
          themeMode: ThemeMode.system,
          theme: theme,
          darkTheme: darkTheme,

          // render now
          home: const SnapScreen(),
        );
      },
    );
  }
}
