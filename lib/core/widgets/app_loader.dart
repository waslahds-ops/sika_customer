import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Reusable loading widget that displays the app's Lottie animation loader
class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 100, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset('assets/lottie/Loader.json', fit: BoxFit.contain),
      ),
    );
  }
}

/// Small inline loader for buttons
class AppButtonLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppButtonLoader({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset('assets/lottie/Loader.json', fit: BoxFit.contain),
    );
  }
}
