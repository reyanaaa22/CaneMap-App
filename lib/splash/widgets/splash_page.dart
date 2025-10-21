import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  final Color background;
  final Widget child;
  const SplashPage({super.key, required this.background, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: child,
    );
  }
}


