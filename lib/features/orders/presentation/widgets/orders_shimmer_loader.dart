import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class OrdersShimmerLoader extends StatelessWidget {
  const OrdersShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ShimmerWidget(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
