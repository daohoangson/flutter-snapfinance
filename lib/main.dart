import 'package:flutter/material.dart';
import 'package:snapfinance/3rdparty/ml/on_device_ocr.dart';
import 'package:snapfinance/screens/snap/snap_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ocr = OnDeviceOcr();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Finance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SnapScreen(
        ocr: ocr,
      ),
    );
  }
}
