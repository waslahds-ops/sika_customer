import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Features section displaying app capabilities
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _TinyFeatureCard(
              icon: Icons.local_offer,
              title: l10n.offers,
              color: const Color(0xFFFF6B35),
            ),
            const SizedBox(width: 10),
            _TinyFeatureCard(
              icon: Icons.flash_on,
              title: l10n.fast,
              color: const Color(0xFFFFD54F),
            ),
            const SizedBox(width: 10),
            _TinyFeatureCard(
              icon: Icons.security,
              title: l10n.safe,
              color: const Color(0xFF00D9B5),
            ),
            const SizedBox(width: 10),
            _TinyFeatureCard(
              icon: Icons.headset_mic,
              title: l10n.support,
              color: const Color(0xFF6C5CE7),
            ),
            const SizedBox(width: 10),
            _TinyFeatureCard(
              icon: Icons.star,
              title: l10n.quality,
              color: const Color(0xFFE94560),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny rectangular feature card
class _TinyFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _TinyFeatureCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
