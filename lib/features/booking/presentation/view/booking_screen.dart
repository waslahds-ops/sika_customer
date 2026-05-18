import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/features/home/presentation/widgets/glovo_bottom_nav_bar.dart';
import 'package:sika_customer/l10n/app_localizations.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = _bookingServices;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.home,
      l10n.orders,
      l10n.butler,
      l10n.profile,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Booking',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category chips
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _BookingChip(service: service);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: services.length,
              ),
            ),

            const SizedBox(height: 18),

            // Big cards
            ...services.map((s) => _BookingCard(service: s)).toList(),
          ],
        ),
      ),
      bottomNavigationBar: GlovoBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _handleNavTap(context, index),
        activeIcons: glovoActiveNavIcons,
        inactiveIcons: glovoInactiveNavIcons,
        labels: labels,
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('main');
        break;
      case 1:
        context.goNamed('my-orders');
        break;
      case 2:
        // Already on booking screen.
        break;
      case 3:
        context.goNamed('main');
        break;
    }
  }
}

class _BookingService {
  final String title;
  final String imageUrl;
  final String iconUrl;

  const _BookingService({
    required this.title,
    required this.imageUrl,
    required this.iconUrl,
  });
}

const _bookingServices = <_BookingService>[
  _BookingService(
    title: 'Barbar Shop',
    imageUrl:
        'https://images.unsplash.com/photo-1517832606299-7ae9b720a186?auto=format&fit=crop&w=1200&q=80',
    iconUrl:
        'https://cdn-icons-png.flaticon.com/512/4075/4075875.png',
  ),
  _BookingService(
    title: 'Makeup Artist',
    imageUrl:
        'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1200&q=80',
    iconUrl:
        'https://cdn-icons-png.flaticon.com/512/921/921051.png',
  ),
  _BookingService(
    title: 'Massage',
    imageUrl:
        'https://images.unsplash.com/photo-1519823551278-64ac92734fb1?auto=format&fit=crop&w=1200&q=80',
    iconUrl:
        'https://cdn-icons-png.flaticon.com/512/2966/2966489.png',
  ),
  _BookingService(
    title: 'Spa',
    imageUrl:
        'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=1200&q=80',
    iconUrl:
        'https://cdn-icons-png.flaticon.com/512/2966/2966506.png',
  ),
];

class _BookingChip extends StatelessWidget {
  final _BookingService service;

  const _BookingChip({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
       
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.network(
                service.iconUrl,
                height: 42,
                width: 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _BookingService service;

  const _BookingCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 16 / 8,
              child: Image.network(
                service.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image, size: 48)),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
