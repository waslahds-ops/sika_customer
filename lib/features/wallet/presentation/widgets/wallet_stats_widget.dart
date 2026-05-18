import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/core/utils/localization_helper.dart';
import 'package:sika_customer/core/providers/country_currency_provider.dart';
import 'package:sika_customer/features/wallet/domain/entities/wallet_entity.dart';

class WalletStatsWidget extends ConsumerWidget {
  final WalletEntity wallet;

  const WalletStatsWidget({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.trending_up,
          label: t(context, 'totalEarned'),
          value: ref
              .read(countryCurrencyProvider.notifier)
              .formatConvertedPriceWithSymbolFromUsd(wallet.totalEarned),
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.trending_down,
          label: t(context, 'totalSpent'),
          value: ref
              .read(countryCurrencyProvider.notifier)
              .formatConvertedPriceWithSymbolFromUsd(wallet.totalSpent),
          color: Colors.red,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
