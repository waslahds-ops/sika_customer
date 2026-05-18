import 'package:flutter/material.dart';

import '../../../core/constants/app_pallete.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPageWidget({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: AppPallete.primaryGreenLight.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                image,
                height: 250,
                width: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback illustration with icons
                  return const FallbackIllustration();
                },
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppPallete.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: AppPallete.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FallbackIllustration extends StatelessWidget {
  const FallbackIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Person illustration placeholder
        Icon(Icons.person, size: 80, color: AppPallete.primaryGreenLight),
        // Food icons around
        Positioned(
          top: 40,
          right: 60,
          child: Icon(Icons.fastfood, size: 40, color: AppPallete.lime),
        ),
        Positioned(
          top: 80,
          left: 50,
          child: Icon(
            Icons.local_pizza,
            size: 35,
            color: AppPallete.primaryGreenLight,
          ),
        ),
        Positioned(
          bottom: 60,
          right: 50,
          child: Icon(
            Icons.restaurant,
            size: 35,
            color: AppPallete.primaryGreen,
          ),
        ),
        Positioned(
          bottom: 80,
          left: 60,
          child: Icon(Icons.lunch_dining, size: 30, color: AppPallete.lime),
        ),
      ],
    );
  }
}

