import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String imageIcon;
  final String title;
  final String price;
  final String originalPrice;
  final String discount;
  final String deliveryTime;
  final bool isFree;

  const MealCard({
    super.key,
    required this.imageIcon,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.deliveryTime,
    this.isFree = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area with discount badge
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForTitle(title),
                    color: Colors.grey[700],
                    size: 48,
                  ),
                ),
              ),
              // Discount badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'LBP ${((double.tryParse(price.toString()) ?? 0) * 89000).toInt()}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      color: Colors.teal,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFree ? 'Free' : 'Paid',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deliveryTime,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    if (title.toLowerCase().contains('kofta')) {
      return Icons.restaurant;
    } else if (title.toLowerCase().contains('bukhuri')) {
      return Icons.local_fire_department;
    } else if (title.toLowerCase().contains('pasta')) {
      return Icons.restaurant_menu;
    }
    return Icons.food_bank;
  }
}

class MealForOneSection extends StatelessWidget {
  const MealForOneSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Show empty state if no products under price limit
    return const SizedBox.shrink();
  }
}
