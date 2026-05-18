import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class SearchShimmerLoader extends StatelessWidget {
  const SearchShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return ShimmerWidget(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(16),
              );
            },
          ),
        ),
      ],
    );
  }
}
