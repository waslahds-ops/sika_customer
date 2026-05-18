import 'package:flutter/material.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class FoodDetailShimmerLoader extends StatelessWidget {
  const FoodDetailShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ShimmerCircle(size: 40),
                  ShimmerLine(width: 100, height: 18),
                  const ShimmerCircle(size: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Image
                    Center(
                      child: ShimmerWidget(
                        width: 280,
                        height: 280,
                        borderRadius: BorderRadius.circular(140),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          ShimmerLine(width: 200, height: 28),
                          const SizedBox(height: 8),
                          // Price
                          ShimmerLine(width: 100, height: 24),
                          const SizedBox(height: 16),
                          // Rating
                          Row(
                            children: [
                              const ShimmerCircle(size: 20),
                              const SizedBox(width: 4),
                              ShimmerLine(width: 80, height: 16),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Size Section
                          ShimmerLine(width: 60, height: 16),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: const ShimmerCircle(size: 50),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          // Ingredients Section
                          ShimmerLine(width: 100, height: 16),
                          const SizedBox(height: 12),
                          Column(
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ShimmerLine(
                                  width: double.infinity,
                                  height: 14,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          // About Section
                          ShimmerLine(width: 80, height: 16),
                          const SizedBox(height: 12),
                          Column(
                            children: List.generate(4, (index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ShimmerLine(
                                  width: double.infinity,
                                  height: 14,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ShimmerWidget(
                    width: 120,
                    height: 50,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShimmerWidget(
                      width: double.infinity,
                      height: 50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

