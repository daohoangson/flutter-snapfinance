import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:snapfinance/widgets/icons/user_icon.dart';
import 'package:snapfinance/widgets/nope.dart';

class SnapIcons extends StatelessWidget {
  const SnapIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: const [
          Expanded(child: nope),
          UserIcon(),
        ],
      ),
    );
  }
}
