import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../l10n/app_localizations.dart';

class PromotionalBadgesWidget extends StatelessWidget {
  final List<PromotionalBadge> badges;
  final EdgeInsets padding;

  const PromotionalBadgesWidget({
    super.key,
    required this.badges,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: badges
            .map((badge) => _buildBadge(context, badge))
            .toList(),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, PromotionalBadge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badge.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: badge.borderColor != null
            ? Border.all(color: badge.borderColor!)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.icon != null) ...[
            badge.icon!,
            const SizedBox(width: 8),
          ],
          Text(
            badge.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badge.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PromotionalBadge {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final Color? borderColor;

  PromotionalBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.borderColor,
  });
}

class RewardsCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final int ordersRemaining;
  final int totalOrders;
  final String rewardAmount;
  final String minimumSpend;

  const RewardsCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ordersRemaining,
    required this.totalOrders,
    required this.rewardAmount,
    required this.minimumSpend,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = ((totalOrders - ordersRemaining) / totalOrders).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and subtitle
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          RewardsProgressLottie(
            totalOrders: totalOrders,
            completedOrders: (totalOrders - ordersRemaining).clamp(0, totalOrders),
          ),
        ],
      ),
    );
  }
}

class RewardsProgressLottie extends StatelessWidget {
  final int totalOrders;
  final int completedOrders;

  const RewardsProgressLottie({
    super.key,
    required this.totalOrders,
    required this.completedOrders,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        children: List.generate(
          totalOrders,
          (index) => Expanded(
            child: RewardsCircleLottie(
              key: ValueKey('rewards-circle-'),
              isCompleted: index < completedOrders,
            ),
          ),
        ),
      ),
    );
  }
}

class RewardsCircleLottie extends StatefulWidget {
  final bool isCompleted;

  const RewardsCircleLottie({
    super.key,
    required this.isCompleted,
  });

  @override
  State<RewardsCircleLottie> createState() => _RewardsCircleLottieState();
}

class _RewardsCircleLottieState extends State<RewardsCircleLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animationComplete = false;
  bool _hasAnimationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _animationComplete = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCompositionLoaded(LottieComposition composition) {
    if (_hasAnimationStarted) return;
    _hasAnimationStarted = true;
    _controller.duration = composition.duration;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCompleted
                  ? const Color(0xFF4CAF50)
                  : Colors.grey[300],
            ),
          ),
          if (!_animationComplete)
            Lottie.asset(
              'assets/lottie/checked.json',
              controller: _controller,
              height: 80,
              fit: BoxFit.contain,
              repeat: false,
              onLoaded: _onCompositionLoaded,
            )
          else
            Image.asset(
              'assets/images/sika_stamp.png',
              height: 26,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }
}

class OfferBannerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;

  const OfferBannerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
