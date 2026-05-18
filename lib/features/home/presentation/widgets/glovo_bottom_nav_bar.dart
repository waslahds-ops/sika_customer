import 'package:flutter/material.dart';

const double glovoNavButtonWidth = 70;

const List<String> glovoActiveNavIcons = [
  'assets/images/home-filled.png',
  'assets/images/orders-filled.png',
  'assets/images/butler-filled.png',
  'assets/images/profile-filled.png',
];

const List<String> glovoInactiveNavIcons = [
  'assets/images/home.png',
  'assets/images/orders.png',
  'assets/images/butler.png',
  'assets/images/profile.png',
];

class GlovoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> activeIcons;
  final List<String> inactiveIcons;
  final List<String> labels;

  const GlovoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.activeIcons,
    required this.inactiveIcons,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    const double height = 60;

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Column(
            children: [
              Divider(height: 2, color: Colors.grey[300]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(labels.length, (index) {
                  final isActive = index == currentIndex;
                  return _NavButton(
                    key: ValueKey('nav_button_${index}_$isActive'),
                    isActive: isActive,
                    icon: isActive ? activeIcons[index] : inactiveIcons[index],
                    label: labels[index],
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final bool isActive;
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        width: glovoNavButtonWidth,
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Image.asset(
              icon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              key: ValueKey(
                '$icon-${DateTime.now().millisecondsSinceEpoch}',
              ),
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
