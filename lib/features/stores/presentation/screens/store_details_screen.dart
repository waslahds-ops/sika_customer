import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../profile/presentation/providers/favorites_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../models/product.dart' as models;
import '../../../models/product.dart';
import '../../domain/entities/store_entities.dart';
import '../widgets/promotional_widgets.dart';
import 'popular_more_screen.dart';

// Provider to fetch available vouchers (cached to prevent repeated API calls)
final _availableVouchersProvider = FutureProvider<List<dynamic>>((ref) async {
  final useCase = ref.read(getCustomerPromoCodesUseCaseProvider);
  final result = await useCase();
  return result.fold((failure) => <dynamic>[], (voucherList) => voucherList);
});

// Provider to fetch active promotions for a store (merchant-managed)
final storePromotionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, storeId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.get('/stores/$storeId/promotions');
    final data = response is Map<String, dynamic> ? response['data'] : null;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  } catch (e) {
    debugPrint('❌ [Store Promotions] $e');
  }
  return <Map<String, dynamic>>[];
});

class StoreDetailsScreen extends ConsumerStatefulWidget {
  final StoreEntity store;

  const StoreDetailsScreen({super.key, required this.store});

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen> {
  late ScrollController _scrollController;
  bool _isAppBarExpanded = true;
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _productsLoaded = false;
  double _containerOpacity = 1.0;
  
  // For Sika Fresh store specific features
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    print(
      '🔍 [PRODUCTS] StoreDetailsScreen initState called for store: ${widget.store.storeId}',
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _voucherController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Format order count for display (e.g., 10000 -> "10k+", 1500000 -> "1.5M+")
  String _formatOrderCount(int count) {
    if (count >= 1000000) {
      return '(${(count / 1000000).toStringAsFixed(1)}M+)';
    } else if (count >= 1000) {
      return '(${(count / 1000).toStringAsFixed(1)}k+)';
    } else {
      return '($count)';
    }
  }

  /// Check if this is a Sika Fresh store
  bool _isSikaFreshStore() {
    return widget.store.name.toLowerCase().contains('sika fresh');
  }

  void _onScroll() {
    // Calculate opacity - stay visible until app bar collapses, then fade out
    final scrollOffset = _scrollController.offset;
    double newOpacity = 1.0;
    
    if (scrollOffset > 120) {
      newOpacity = 0.0;
    } else if (scrollOffset > 80) {
      newOpacity = 1.0 - ((scrollOffset - 80) / 40);
    }
    
    setState(() {
      _containerOpacity = newOpacity;
      if (_scrollController.offset > 120 && _isAppBarExpanded) {
        _isAppBarExpanded = false;
      } else if (_scrollController.offset <= 120 && !_isAppBarExpanded) {
        _isAppBarExpanded = true;
      }
    });
  }

  /// Calculate header position to make it stick at the top when scrolling
  double _calculateHeaderTop(double initialTop) {
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    // When scroll offset exceeds initialTop, pin the header at the top (with AppBar height)
    if (scrollOffset >= initialTop) {
      return 56.0; // Stick below the pinned AppBar
    }
    // Otherwise, position it at initial position minus scroll offset
    return initialTop - scrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(storesProvider);
    final products = storesState.products;
    final isLoading = storesState.isLoading;

    // Load products for this store only once
    if (!_productsLoaded && products.isEmpty && !isLoading) {
      _productsLoaded = true;
      Future.microtask(() {
        print(
          '🔍 [PRODUCTS] Loading products in build for store: ${widget.store.storeId}',
        );
        ref
            .read(storesProvider.notifier)
            .loadProductsByStore(widget.store.storeId);
      });
    }

    // Filter products by store
    final storeProducts = products
        .where((product) => product.storeId == widget.store.storeId)
        .toList();

    if (storesState.errorMessage != null) {
      debugPrint('Error: ${storesState.errorMessage}');
    }

    // Check if it's Sika Fresh store
    final isSikaFresh = _isSikaFreshStore();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isSikaFresh 
          ? _buildSikaFreshLayout(context, storeProducts, isLoading)
          : _buildDefaultLayout(context, storeProducts, isLoading),
        bottomNavigationBar: isSikaFresh
          ? _buildBottomNavigation()
          : null,
      ),
    );
  }

  /// Build the default layout for non-Sika Fresh stores
  Widget _buildDefaultLayout(BuildContext context, List<ProductEntity> storeProducts, bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive padding and sizes
        final isSmallScreen = constraints.maxWidth < 360;
        final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
        final popularProducts = storeProducts.take(7).toList();
        final specialOfferProducts = storeProducts.skip(7).take(4).toList();
        
        return Stack(
          children: [
            // Scrollable content layer
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(),
                // Spacer for the header that will overlay
                SliverToBoxAdapter(
                  child: SizedBox(height: 90), // Space for overlapping header
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final promotionsAsync = ref.watch(
                            storePromotionsProvider(widget.store.storeId),
                          );

                          String? promoLabel;
                          promotionsAsync.maybeWhen(
                            data: (promos) {
                              if (promos.isNotEmpty) {
                                promoLabel =
                                    _formatPromotionLabel(context, promos.first);
                              }
                            },
                            orElse: () {},
                          );

                          final badges = <PromotionalBadge>[
                            if (promoLabel != null)
                              PromotionalBadge(
                                label: promoLabel!,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                borderColor: Colors.grey[200],
                                icon: Image.asset(
                                  'assets/icons/rewards.png',
                                  width: 14,
                                  height: 14,
                                ),
                              ),
                            PromotionalBadge(
                              label: AppLocalizations.of(context)!.earnPoints,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              borderColor: Colors.grey[200],
                              icon: Image.asset(
                                'assets/icons/points.png',
                                width: 14,
                                height: 14,
                              ),
                            ),
                          ];

                          if (badges.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return PromotionalBadgesWidget(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            badges: badges,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      RewardsCardWidget(
                        title: 'place 4 orders and earn LBP 450,000',
                        subtitle: 'LBP 450,000 minimum spend',
                        ordersRemaining: 4,
                        totalOrders: 4,
                        rewardAmount: 'LBP 450,000',
                        minimumSpend: 'LBP 450,000',
                      ),
                      const SizedBox(height: 4),
                      if (isLoading)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      else if (storeProducts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                child: Text(
                                  AppLocalizations.of(context)!.noProductsAvailableAtThisTime,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _buildSectionTitle(
                          context,
                          title: AppLocalizations.of(context)!.popularBadge,
                          horizontalPadding: horizontalPadding,
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PopularMoreScreen(
                                  products: storeProducts,
                                  store: widget.store,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildPopularHorizontalList(
                          popularProducts,
                          horizontalPadding: horizontalPadding,
                        ),
                        const SizedBox(height: 8),
                        _buildSectionTitle(
                          context,
                          title: 'Special Offers',
                          horizontalPadding: horizontalPadding,
                        ),
                        _buildProductGrid(
                          specialOfferProducts,
                          horizontalPadding: horizontalPadding,
                        ),
                        const SizedBox(height: 4),
                      ],
                      OfferBannerWidget(
                        title: 'Speed LBP 450,000 & earn punch',
                        subtitle: ' ',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Floating header - positioned IN FRONT of everything
            Positioned(
              top: _calculateHeaderTop(190), // Stick at top when scrolling
              left: horizontalPadding,
              right: horizontalPadding,
              child: Opacity(
                opacity: _containerOpacity,
                child: _buildResponsiveStoreHeader(constraints),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build the Sika Fresh specific layout
  Widget _buildSikaFreshLayout(BuildContext context, List<ProductEntity> storeProducts, bool isLoading) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: SizedBox(height: 120)),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [
                  // Rewards and Earn Points badges
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFBFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/rewards.png',
                                width: 12,
                                height: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.rewards,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFBFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/points.png',
                                width: 12,
                                height: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.earnPoints,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search,
                        hintStyle: const TextStyle(color: Colors.black),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            color: Colors.black,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Tab-based content
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchAisles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // On error, show the default products list instead
                  print('⚠️ Failed to load aisles, showing default products list');
                  if (storeProducts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noProductsAvailableAtThisTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildProductsList(storeProducts);
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: const Center(child: Text('No aisles available')),
                    ),
                  );
                }

                final aislesData = snapshot.data!['data'] as List? ?? [];
                
                // Convert to list of maps
                final List<Map<String, dynamic>> aisles = aislesData
                    .map((item) => item as Map<String, dynamic>)
                    .toList();

                if (aisles.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.noProductsAvailableAtThisTime,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                if (_selectedTabIndex == 0) {
                  // Shop tab - show all aisles as grid
                  return SliverToBoxAdapter(
                    child: _buildAislesGridViewFromApi(aisles),
                  );
                } else if (_selectedTabIndex == 1) {
                  // Aisles tab - show list of aisles
                  return SliverToBoxAdapter(
                    child: _buildAislesListFromApi(aisles),
                  );
                } else if (_selectedTabIndex == 2) {
                  // Offers tab
                  return SliverToBoxAdapter(
                    child: _buildOffersTab(),
                  );
                } else {
                  // Buy Again tab
                  return SliverToBoxAdapter(
                    child: _buildBuyAgainTab(),
                  );
                }
              },
            ),
          ],
        ),
        // Floating header
        Positioned(
          top: _calculateHeaderTop(190),
          left: 16,
          right: 16,
          child: Opacity(
            opacity: _containerOpacity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _buildResponsiveStoreHeader(constraints);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Fetch aisles from backend API
  Future<Map<String, dynamic>> _fetchAisles() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.getStoreAisles(widget.store.storeId);
      return result;
    } catch (e) {
      print('❌ Error fetching aisles: $e');
      rethrow;
    }
  }

  /// Build aisles grid view from API data
  Widget _buildAislesGridViewFromApi(List<Map<String, dynamic>> aisles) {
    if (aisles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noProductsAvailableAtThisTime,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: aisles.length,
        itemBuilder: (context, index) {
          final aisle = aisles[index];
          final aisleName = aisle['name'] ?? 'Unknown';
          final productCount = aisle['product_count'] ?? 0;
          final imageUrl = aisle['image_url'];

          return GestureDetector(
            onTap: () {
              _selectedTabIndex = 1;
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: imageUrl != null && imageUrl.toString().isNotEmpty
                          ? Image.network(
                              ImageUrlHelper.toFullUrl(imageUrl.toString()) ?? '',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            aisleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$productCount items',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build aisles list view from API data
  Widget _buildAislesListFromApi(List<Map<String, dynamic>> aisles) {
    if (aisles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noProductsAvailableAtThisTime,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: aisles.map((aisle) {
          final aisleName = aisle['name'] ?? 'Unknown';
          final productCount = aisle['product_count'] ?? 0;
          final imageUrl = aisle['image_url'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                // Navigate to aisle products
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                      child: imageUrl != null && imageUrl.toString().isNotEmpty
                          ? Image.network(
                              ImageUrlHelper.toFullUrl(imageUrl.toString()) ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              aisleName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$productCount products',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build offers tab content
  Widget _buildOffersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Special Offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for special promotions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPromotionLabel(
    BuildContext context,
    Map<String, dynamic> promo,
  ) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final title = localeCode.startsWith('ar')
        ? (promo['title_ar'] ?? promo['title_en'] ?? promo['title'])
        : (promo['title_en'] ?? promo['title_ar'] ?? promo['title']);

    final discountType = promo['discount_type']?.toString();
    final discountValue = promo['discount_value'];
    final maxDiscount = promo['max_discount_amount'];

    String? discountPart;
    if (discountValue != null) {
      if (discountType == 'percentage' || discountType == 'percent') {
        discountPart = '${discountValue.toString()}%';
      } else {
        discountPart = 'LBP ${discountValue.toString()}';
      }
    }

    String maxPart = '';
    if (maxDiscount != null) {
      maxPart = ' (max LBP ${maxDiscount.toString()})';
    }

    if (title != null && title.toString().isNotEmpty) {
      return title.toString();
    }

    if (discountPart != null) {
      return '$discountPart off$maxPart';
    }

    return AppLocalizations.of(context)!.specialOffer;
  }

  /// Build buy again tab content
  Widget _buildBuyAgainTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Buy Again',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your previous orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build bottom navigation for Sika Fresh
  Widget _buildBottomNavigation() {
    return Container(
      
      decoration: BoxDecoration(    
        color: Color(0xFFFFFFFF),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/shop.png',
              width: 24,
              height: 24,
            ),
            label: AppLocalizations.of(context)!.shop,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/aisles.png',
              width: 24,
              height: 24,
            ),
            label: AppLocalizations.of(context)!.aisles,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/offers.png',
              width: 24,
              height: 24,
            ),
            label: AppLocalizations.of(context)!.offers,
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/buy_again.png',
              width: 24,
              height: 24,
            ),
            label: AppLocalizations.of(context)!.buyAgain,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final coverUrl = widget.store.coverUrl?.isNotEmpty == true
        ? widget.store.coverUrl
        : widget.store.logoUrl;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _isAppBarExpanded 
          ? Colors.white 
          : Colors.black.withValues(alpha: 0.3),
      elevation: 0,
      title: _isAppBarExpanded
          ? null
          : Text(
              widget.store.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final isFavorite = ref
                  .watch(favoritesProvider)
                  .contains(widget.store.storeId);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFFF6B35) : Colors.black,
                ),
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(widget.store.storeId);
               
                },
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
        ],
        collapseMode: CollapseMode.parallax,
        background: coverUrl != null && coverUrl.isNotEmpty
            ? Image.network(
                ImageUrlHelper.toFullUrl(coverUrl) ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.restaurant,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
      ),
    );
  }

  Widget _buildResponsiveStoreHeader(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 360;
    final containerPadding = isSmallScreen ? 12.0 : 16.0;
    final logoSize = isSmallScreen ? 36.0 : 40.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Store Logo and Name in Row
          Row(
            children: [
              Container(                
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: widget.store.logoUrl != null && widget.store.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          ImageUrlHelper.toFullUrl(widget.store.logoUrl) ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                widget.store.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.store.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Text(
                  widget.store.name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey[500]),
          SizedBox(height: isSmallScreen ? 10 : 16),
          // Pre-order and Rating section
          Row(
            children: [
              // Pre-order section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.deliveryTime,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDeliveryTime(widget.store.estimatedDeliveryTime),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),            
              // Rating section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.ratingAndReviews,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: isSmallScreen ? 14 : 16,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                        child: Text(
                          widget.store.ratingAvg?.toStringAsFixed(1) ?? '4.9',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.store.ordersCount != null 
                                ? _formatOrderCount(widget.store.ordersCount!)
                                : '(0)',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoriesSection() {
    final storesState = ref.watch(storesProvider);
    final products = storesState.products
        .where((product) => product.storeId == widget.store.storeId)
        .toList();

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group products by category
    final Map<String, List<ProductEntity>> groupedProducts = {};
    for (var product in products) {
      final category = product.category ?? 'Other';
      groupedProducts.putIfAbsent(category, () => []).add(product);
    }

    // Get first category with products
    final firstCategory = groupedProducts.keys.firstOrNull;
    if (firstCategory == null) return const SizedBox.shrink();

    final categoryProducts = groupedProducts[firstCategory] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                firstCategory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: categoryProducts.length,
            itemBuilder: (context, index) {
              final product = categoryProducts[index];
              return GestureDetector(
                onTap: () => _showProductDetail(product),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty
                            ? Image.network(
                                ImageUrlHelper.toFullUrl(product.imageUrl) ??
                                    '',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.nameEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ref
                                    .read(countryCurrencyProvider.notifier)
                                    .formatConvertedPriceWithSymbolFromUsd(
                                      product.price,
                                    ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _showProductDetail(product),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(Icons.add,
                                          size: 18, color: Colors.black),
                                    ),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            _showProductDetail(product);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nameEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (product.descriptionEn != null)
                        Text(
                          product.descriptionEn!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        ref
                            .read(countryCurrencyProvider.notifier)
                            .formatConvertedPriceWithSymbolFromUsd(
                              product.price,
                            ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(
                              ImageUrlHelper.toFullUrl(product.imageUrl) ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          _showProductDetail(product);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.add, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }, childCount: products.length),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required double horizontalPadding,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        mainAxisAlignment:
            onSeeAll != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                AppLocalizations.of(context)!.seeAll,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    List<ProductEntity> products, {
    required double horizontalPadding,
  }) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => _showProductDetail(product),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              ImageUrlHelper.toFullUrl(product.imageUrl) ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                );
                              },
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                          ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _buildAddButton(() => _addProductToCart(product)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularHorizontalList(
    List<ProductEntity> products, {
    required double horizontalPadding,
  }) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length.clamp(0, 7),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => _showProductDetail(product),
            child: Container(
              width: 156,
              height: 89,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(
                              ImageUrlHelper.toFullUrl(product.imageUrl) ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: Colors.grey[200]);
                              },
                            )
                          : Container(color: Colors.grey[200]),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _buildAddButton(() => _addProductToCart(product)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDeliveryTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '15-30 mins';
    }
    if (raw.contains('min')) {
      return raw;
    }
    return '$raw mins';
  }

  Widget _buildAddButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFFFDB92A),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  void _addProductToCart(ProductEntity product) {
    final productModel = models.Product(
      productId: product.productId,
      storeId: product.storeId,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      descriptionAr: product.descriptionAr,
      descriptionEn: product.descriptionEn,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      isAvailable: product.isAvailable,
      preparationTime: product.preparationTime,
    );

    final result = ref
        .read(cartProvider.notifier)
        .addItem(productModel, quantity: 1, force: false);

    if (result == AddItemResult.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${product.nameEn} ${AppLocalizations.of(context)!.addedToCart}',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    } else if (result == AddItemResult.conflict) {
      // Replace cart with current store items
      ref
          .read(cartProvider.notifier)
          .addItem(productModel, quantity: 1, force: true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${product.nameEn} ${AppLocalizations.of(context)!.addedToCart} (${widget.store.name})',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    } else if (result == AddItemResult.requiresVerification) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.pleaseLoginFirst ??
                  'Please login to continue',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _showProductDetail(ProductEntity product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailSheet(product: product),
    );
  }
}

class _ProductDetailSheet extends ConsumerStatefulWidget {
  final ProductEntity product;

  const _ProductDetailSheet({required this.product});

  @override
  ConsumerState<_ProductDetailSheet> createState() =>
      _ProductDetailSheetState();
}

class _ProductDetailSheetState extends ConsumerState<_ProductDetailSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        widget.product.nameEn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.product.imageUrl != null &&
                        widget.product.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ImageUrlHelper.toFullUrl(widget.product.imageUrl) ??
                              '',
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      widget.product.nameEn,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ref
                          .read(countryCurrencyProvider.notifier)
                          .formatConvertedPriceWithSymbolFromUsd(
                            widget.product.price,
                          ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.product.descriptionEn != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.product.descriptionEn!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final product = Product(
                              productId: widget.product.productId,
                              storeId: widget.product.storeId,
                              nameAr: widget.product.nameAr,
                              nameEn: widget.product.nameEn,
                              descriptionAr: widget.product.descriptionAr,
                              descriptionEn: widget.product.descriptionEn,
                              price: widget.product.price,
                              imageUrl: widget.product.imageUrl,
                              category: widget.product.category,
                              isAvailable: widget.product.isAvailable,
                              preparationTime: widget.product.preparationTime,
                            );

                            ref
                                .read(cartProvider.notifier)
                                .addItem(product, quantity: _quantity);

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.product.nameEn} (x$_quantity) ${AppLocalizations.of(context)!.addedToCart}',
                                ),
                                backgroundColor: AppPallete.primaryTeal,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            '${AppLocalizations.of(context)!.addToCart}  ${ref.read(countryCurrencyProvider.notifier).formatConvertedPriceWithSymbolFromUsd(widget.product.price * _quantity)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _VouchersBottomSheet extends ConsumerStatefulWidget {
  final TextEditingController voucherController;
  final String? appliedVoucher;
  final String? voucherError;
  final VoidCallback onApplyVoucher;
  final Function(String) onVoucherTap;
  final VoidCallback onClearVoucher;

  const _VouchersBottomSheet({
    required this.voucherController,
    required this.appliedVoucher,
    required this.voucherError,
    required this.onApplyVoucher,
    required this.onVoucherTap,
    required this.onClearVoucher,
  });

  @override
  ConsumerState<_VouchersBottomSheet> createState() =>
      _VouchersBottomSheetState();
}

class _VouchersBottomSheetState extends ConsumerState<_VouchersBottomSheet> {
  late TextEditingController _localVoucherController;

  @override
  void initState() {
    super.initState();
    _localVoucherController = TextEditingController();
  }

  @override
  void dispose() {
    _localVoucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    const Text(
                      'Available Vouchers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Apply Voucher Input Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apply Voucher Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _localVoucherController,
                            decoration: InputDecoration(
                              hintText: 'Enter voucher code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (_localVoucherController.text.isNotEmpty) {
                              widget.voucherController.text =
                                  _localVoucherController.text;
                              widget.onApplyVoucher();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryYellow,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.voucherError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.voucherError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (widget.appliedVoucher != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Voucher ${widget.appliedVoucher} applied',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: widget.onClearVoucher,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Vouchers List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Your Available Vouchers',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVouchersListWidget(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVouchersListWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final vouchersAsync = ref.watch(_availableVouchersProvider);

        return vouchersAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Could not load vouchers',
              style: TextStyle(color: Colors.orange[800], fontSize: 12),
            ),
          ),
          data: (vouchersData) {
            final vouchers = <Map<String, dynamic>>[];
            vouchers.addAll(vouchersData.whereType<Map<String, dynamic>>());

            if (vouchers.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No available vouchers',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              );
            }

            return Column(
              children: vouchers.map((voucher) {
                final code = voucher['code'] ?? 'N/A';
                final title = voucher['title'] ?? voucher['code'] ?? '';
                final description = voucher['description'] ?? '';
                final discount =
                    voucher['discount_percentage'] ?? voucher['discount'] ?? 0;
                final maxSavings =
                    voucher['max_savings'] ?? voucher['max_discount'] ?? 'N/A';
                final validUntil = voucher['valid_until'];
                final minOrder = voucher['min_order_amount'];

                return GestureDetector(
                  onTap: () {
                    widget.onVoucherTap(code);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.appliedVoucher == code
                            ? AppPallete.primaryYellow
                            : Colors.grey.shade200,
                        width: widget.appliedVoucher == code ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Discount + Title + Applied Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Discount Icon & Amount
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.card_giftcard,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title & Discount
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Discount Percentage
                                  Text(
                                    '$discount% off',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  // Title
                                  if (title.isNotEmpty)
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Applied Badge
                            if (widget.appliedVoucher == code)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppPallete.primaryYellow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Applied ✓',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        if (description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Details Row: Min Order, Max Savings, Valid Until
                        Row(
                          children: [
                            // Min Order
                            if (minOrder != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Min. order',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      minOrder is num
                                          ? '\$$minOrder'
                                          : minOrder.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Max Savings
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Save up to',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    maxSavings is num
                                        ? '\$$maxSavings'
                                        : maxSavings.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Valid Until
                            if (validUntil != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Valid until',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _formatDate(validUntil),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // Voucher Code at Bottom
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                code,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsed = DateTime.parse(date);
        return '${parsed.day.toString().padLeft(2, '0')} ${_getMonthName(parsed.month)}';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
