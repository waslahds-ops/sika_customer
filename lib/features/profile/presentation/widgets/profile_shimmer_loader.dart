import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/injection_container.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class ProfileShimmerLoader extends StatelessWidget {
  const ProfileShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              ShimmerLine(width: 140, height: 28),
              const SizedBox(height: 24),
              // Card placeholder
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget(
                      width: MediaQuery.of(context).size.width / 3,
                      height: 80,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.white,
                    ),
                    if (authState.isAuthenticated) ...[
                      Container(width: 1, height: 80, color: Colors.grey),
                      ShimmerWidget(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                      ),
                    ],
                    Container(width: 1, height: 80, color: Colors.grey),
                    ShimmerWidget(
                      width: MediaQuery.of(context).size.width / 3,
                      height: 80,
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Menu rows
              ShimmerWidget(width: MediaQuery.of(context).size.width, height: 60),
              Divider(color: Colors.grey[200]),
              ShimmerWidget(width: MediaQuery.of(context).size.width, height: 60),
              Divider(color: Colors.grey[200]),
              ShimmerWidget(width: MediaQuery.of(context).size.width, height: 60),
              Divider(color: Colors.grey[200]),
              ShimmerWidget(width: MediaQuery.of(context).size.width, height: 60),
            ],
          ),
        );
      },
    );
  }
}
