import 'package:flutter/material.dart';

import '../../../core/constants/app_pallete.dart';

class PageIndicator extends StatelessWidget {
  final bool isActive;

  const PageIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppPallete.primaryGreen : AppPallete.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
