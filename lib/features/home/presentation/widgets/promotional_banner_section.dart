import 'package:flutter/material.dart';

class PromoVoucherCard extends StatelessWidget {
  final String discount;
  final String maxLimit;

  const PromoVoucherCard({
    super.key,
    required this.discount,
    required this.maxLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            maxLimit,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PromotionalBannerSection extends StatelessWidget {
  const PromotionalBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4D3E), Color(0xFF2D6B54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grab 6 New User Vouchers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Worth up to',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '200',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFEB3B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '\$',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFEB3B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Gift box image placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green[300]?.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Voucher cards scroll
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                PromoVoucherCard(
                  discount: '50% off',
                  maxLimit: 'Max 175,000 LBP',
                ),
                const SizedBox(width: 8),
                PromoVoucherCard(
                  discount: '30% off',
                  maxLimit: 'Max 230,000 LBP',
                ),
                const SizedBox(width: 8),
                PromoVoucherCard(
                  discount: '30% off',
                  maxLimit: 'Max 168,000 LBP',
                ),
                const SizedBox(width: 8),
                PromoVoucherCard(
                  discount: '25% off',
                  maxLimit: 'Max 210,000 LBP',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

