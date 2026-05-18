import 'package:flutter/material.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class CartShimmerLoader extends StatelessWidget {
  const CartShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: ShimmerCircle(size: 40),
        ),
        title: ShimmerLine(width: 100, height: 20),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ShimmerWidget(
                    width: double.infinity,
                    height: 120,
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
          ),
          // Bottom Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLine(width: 80, height: 16),
                    ShimmerLine(width: 60, height: 16),
                  ],
                ),
                const SizedBox(height: 12),
                // Delivery
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLine(width: 80, height: 16),
                    ShimmerLine(width: 60, height: 16),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLine(width: 60, height: 20),
                    ShimmerLine(width: 80, height: 24),
                  ],
                ),
                const SizedBox(height: 20),
                // Checkout Button
                ShimmerWidget(
                  width: double.infinity,
                  height: 56,
                  borderRadius: BorderRadius.circular(28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

