import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/src/widgets/framework.dart';

const scheme = FlexScheme.amber;
final theme = FlexThemeData.light(scheme: scheme);
final darkTheme = FlexThemeData.dark(scheme: scheme);

class ThemeApp extends StatefulWidget {
  final Widget Function(BuildContext, ThemeData, ThemeData) builder;

  const ThemeApp({
    required this.builder,
    super.key,
  });

  @override
  State<ThemeApp> createState() => _ThemeAppState();
}

class _ThemeAppState extends State<ThemeApp> {
  @override
  Widget build(BuildContext context) {
    const scheme = FlexScheme.deepOrangeM3;
    final theme = FlexThemeData.light(scheme: scheme, useMaterial3: true);
    final darkTheme = FlexThemeData.dark(scheme: scheme, useMaterial3: true);

    return widget.builder(context, theme, darkTheme);
  }
}
