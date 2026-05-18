import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import 'dart:math';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/providers/favorites_provider.dart';
import '../../domain/entities/store_entities.dart';
import 'store_details_screen.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<StoreEntity> _filteredStores = [];
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Get current location and load stores
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });
      // Load stores with current location
      ref
          .read(storesProvider.notifier)
          .loadStores(latitude: _currentLatitude, longitude: _currentLongitude);
      ref.read(storesProvider.notifier).loadCategories();
    } catch (e) {
      print('Error getting location: $e');
      // Load stores without location
      ref.read(storesProvider.notifier).loadStores();
      ref.read(storesProvider.notifier).loadCategories();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload stores when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _filterStores(String query, List<StoreEntity> allStores) {
    setState(() {
      if (query.isEmpty) {
        _filteredStores = allStores;
      } else {
        _filteredStores = allStores.where((store) {
          return store.name.toLowerCase().contains(query.toLowerCase()) ||
              (store.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  void _applyFilter(String filter, List<StoreEntity> allStores) {
    setState(() {
      _selectedFilter = filter;
      List<StoreEntity> filtered = allStores;

      switch (filter) {
        case 'Nearby':
          // Filter stores within 10km and sort by distance
          filtered =
              (List.from(allStores).where((store) {
                    if (_currentLatitude != null &&
                        _currentLongitude != null &&
                        store.latitude != null &&
                        store.longitude != null) {
                      final distance = _calculateDistance(
                        _currentLatitude!,
                        _currentLongitude!,
                        store.latitude!,
                        store.longitude!,
                      );
                      return distance <= 10.0;
                    }
                    return true;
                  }).toList()
                  as List<StoreEntity>);

          // Sort by distance
          filtered.sort((a, b) {
            if (_currentLatitude != null &&
                _currentLongitude != null &&
                a.latitude != null &&
                a.longitude != null &&
                b.latitude != null &&
                b.longitude != null) {
              final distanceA = _calculateDistance(
                _currentLatitude!,
                _currentLongitude!,
                a.latitude!,
                a.longitude!,
              );
              final distanceB = _calculateDistance(
                _currentLatitude!,
                _currentLongitude!,
                b.latitude!,
                b.longitude!,
              );
              return distanceA.compareTo(distanceB);
            }
            return 0;
          });
          break;
        case 'Top Rated':
          // Sort by rating descending (Popular stores)
          filtered = (List<StoreEntity>.from(allStores))
            ..sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
          break;
        default:
          filtered = allStores;
      }

      _filteredStores = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(storesProvider);
    final allStores = storesState.stores;

    // Use allStores directly if _filteredStores is empty and no search is active
    final displayStores =
        _filteredStores.isEmpty && _searchController.text.isEmpty
        ? allStores
        : _filteredStores;

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppPallete.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Stores',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Discover amazing stores near you',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppPallete.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppPallete.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppPallete.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (query) =>
                                _filterStores(query, allStores),
                            decoration: const InputDecoration(
                              hintText: 'Search for stores, cuisines...',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _filterStores('', allStores);
                            },
                            child: Icon(
                              Icons.close,
                              color: AppPallete.textSecondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == 'All',
                      onTap: () => _applyFilter('All', allStores),
                    ),
                    _FilterChip(
                      label: 'Nearby',
                      icon: Icons.near_me,
                      isSelected: _selectedFilter == 'Nearby',
                      onTap: () => _applyFilter('Nearby', allStores),
                    ),
                    _FilterChip(
                      label: 'Top Rated',
                      icon: Icons.star,
                      isSelected: _selectedFilter == 'Top Rated',
                      onTap: () => _applyFilter('Top Rated', allStores),
                    ),
                  ],
                ),
              ),
            ),

            // Stores List
            Expanded(
              child: storesState.isLoading
                  ? _buildLoadingState()
                  : displayStores.isEmpty && storesState.errorMessage != null
                  ? _buildErrorState(storesState.errorMessage!)
                  : displayStores.isEmpty
                  ? _buildEmptyState()
                  : Stack(
                      children: [
                        // Always show stores list
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate responsive grid columns based on available width
                            final maxWidth = constraints.maxWidth;
                            late int crossAxisCount;
                            late double childAspectRatio;

                            if (maxWidth < 400) {
                              crossAxisCount = 1;
                              childAspectRatio = 1.2;
                            } else if (maxWidth < 600) {
                              crossAxisCount = 1;
                              childAspectRatio = 1.2;
                            } else if (maxWidth < 900) {
                              crossAxisCount = 2;
                              childAspectRatio = 1.1;
                            } else {
                              crossAxisCount = 3;
                              childAspectRatio = 1.0;
                            }

                            // Use GridView for larger screens, ListView for mobile
                            if (maxWidth > 600) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: childAspectRatio,
                                    ),
                                itemCount: displayStores.length,
                                itemBuilder: (context, index) {
                                  final store = displayStores[index];
                                  return _StoreCard(
                                    store: store,
                                    onTap: () {
                                      ref
                                          .read(storesProvider.notifier)
                                          .selectStore(store);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StoreDetailsScreen(store: store),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: displayStores.length,
                                itemBuilder: (context, index) {
                                  final store = displayStores[index];
                                  return _StoreCard(
                                    store: store,
                                    onTap: () {
                                      ref
                                          .read(storesProvider.notifier)
                                          .selectStore(store);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StoreDetailsScreen(store: store),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                        // Show error notification as overlay if error exists
                        if (storesState.errorMessage != null)
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      storesState.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(storesProvider.notifier)
                                          .loadStores();
                                    },
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: AppLoader());
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Oops!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(storesProvider.notifier).loadStores();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryYellow,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noStoresFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppPallete.primaryYellow : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppPallete.primaryYellow
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppPallete.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppPallete.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Store Card Widget
class _StoreCard extends StatelessWidget {
  final StoreEntity store;
  final VoidCallback onTap;

  const _StoreCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Image with overlay
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppPallete.greyLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: store.logoUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            ImageUrlHelper.toFullUrl(store.logoUrl) ?? '',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.store,
                                  size: 64,
                                  color: AppPallete.textTertiary,
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.store,
                            size: 64,
                            color: AppPallete.textTertiary,
                          ),
                        ),
                ),

                // Free Delivery Badge
                if (store.deliveryFee == 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppPallete.primaryYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Free Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Open/Closed Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: store.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      store.isOpen ? 'Open' : 'Closed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Favorite Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final isFavorite = ref
                          .watch(favoritesProvider)
                          .contains(store.storeId);
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isFavorite
                              ? const Color(0xFFFF6B35)
                              : AppPallete.primaryYellow,
                          onPressed: () {
                            ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(store.storeId);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Store Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (store.ratingAvg != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppPallete.primaryYellow.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: AppPallete.primaryYellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                store.ratingAvg!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (store.description != null)
                    Text(
                      store.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPallete.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (store.address != null)
                    Text(
                      store.address!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPallete.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (store.estimatedDeliveryTime != null)
                        _InfoChip(
                          icon: Icons.access_time,
                          text: store.estimatedDeliveryTime!,
                        ),
                      if (store.estimatedDeliveryTime != null)
                        const SizedBox(width: 12),
                      if (store.distance != null)
                        _InfoChip(
                          icon: Icons.location_on,
                          text: store.distance!,
                        ),
                      if (store.distance != null) const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.delivery_dining,
                        text: store.deliveryFee == 0
                            ? 'Free'
                            : '\$${store.deliveryFee.toStringAsFixed(1)}',
                        color: store.deliveryFee == 0 ? Colors.green : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension to calculate distance (mock for now)
extension on StoreEntity {
  String? get distance {
    if (latitude != null && longitude != null) {
      // In real app, calculate distance from user location
      return '${(latitude! * 10).toStringAsFixed(1)} km';
    }
    return null;
  }
}

// Info Chip Widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AppPallete.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color ?? AppPallete.textPrimary,
          ),
        ),
      ],
    );
  }
}
