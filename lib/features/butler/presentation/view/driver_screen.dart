import 'package:flutter/material.dart';
import 'package:sika_customer/l10n/app_localizations.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  late final List<_ButlerService> _services = [
    _ButlerService(
      title: AppLocalizations.of(context)!.deliverYourStuff,
      imageUrl:
          'assets/images/butler1.jpg',
    ),
    _ButlerService(
      title: AppLocalizations.of(context)!.buySomething,
      imageUrl:
          'assets/images/butler2.jpg',
    ),
    _ButlerService(
      title: AppLocalizations.of(context)!.hugeAppliances,
      imageUrl:
          'assets/images/butler3.jpg',
    ),
    _ButlerService(
      title: AppLocalizations.of(context)!.truckEvacuatingCar,
      imageUrl:
          'assets/images/butler4.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.butler,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.weDeliverEverything,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ..._services.map((service) => _ServiceCard(service: service)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ButlerService service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 14 / 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    service.imageUrl,
                    width: 200,
                    height: 100,
                    fit: BoxFit.cover,               
                  ),                 
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ButlerService {
  final String title;
  final String imageUrl;

  const _ButlerService({
    required this.title,
    required this.imageUrl,
  });
}
