import 'package:flutter/material.dart';

class MerchantVoucherDialog extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback onClose;
  final VoidCallback? onAction;

  const MerchantVoucherDialog({
    Key? key,
    required this.imageUrl,
    required this.onClose,
    this.onAction,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (imageUrl != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('Unable to load image'),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(subtitle ?? 'Special vouchers available'),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onClose,
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onAction?.call();
                          onClose();
                        },
                        child: const Text('View Vouchers'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              onPressed: onClose,
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
