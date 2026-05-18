import 'package:flutter/material.dart';
import 'package:sika_customer/l10n/app_localizations.dart';

class WalletPointsPage extends StatelessWidget {
  const WalletPointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {"title": "Order #2981", "points": 18, "date": "Nov 26"},
      {"title": "Order #2972", "points": 24, "date": "Nov 24"},
      {"title": "Order #2950", "points": 12, "date": "Nov 22"},
      {"title": "Promo Reward", "points": 50, "date": "Nov 20"},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wallet),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // POINTS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffFFB800), Color(0xffFF8400)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.yourPoints,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "294",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 294 / 500,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.spendPointsToGetFreeDelivery,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // HEADER
            Text(
              AppLocalizations.of(context)!.pointsHistory,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // TRANSACTIONS LIST
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = transactions[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item["title"].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(item["date"].toString()),
                  trailing: Text(
                    "+${item["points"]} pts",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
