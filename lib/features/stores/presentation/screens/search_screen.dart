import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:sika_customer/features/stores/presentation/providers/stores_provider.dart';
import 'package:sika_customer/features/stores/presentation/screens/food_detail_screen.dart'
    as food_detail;
import 'package:sika_customer/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/store_entities.dart';
import '../../../orders/domain/entities/order_entities.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;

  Box<String>? _recentSearchBox;
  bool _isSearching = false;
  String _searchQuery = '';
  List<OrderEntity> _filteredOrders = [];
  List<StoreEntity> _filteredStores = [];
  List<ProductEntity> _filteredProducts = [];
  List<ProductEntity> _allProducts = [];
  bool _loadingAllProducts = false;
  Timer? _hintTimer;
  List<String> _hintPool = [];
  int _hintIndex = 0;
  String _currentHint = 'Search';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {});
      });

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Initialize Hive box
    _initializeRecent();

    // Load stores, orders, and products data
    Future.microtask(() {
      ref.read(storesProvider.notifier).loadStores();
      ref.read(ordersProvider.notifier).loadOrders();
      // Load all products for searching
      final storesState = ref.read(storesProvider);
      for (var store in storesState.stores) {
        ref.read(storesProvider.notifier).loadProductsByStore(store.storeId);
      }
    });

    // When stores load, prefetch products across all of them for search
    // Auto-focus search field
    Future.delayed(const Duration(milliseconds: 100), () {
      _searchFocusNode.requestFocus();
    });

    _searchController.addListener(_onSearchChanged);
    _startHintRotation();
  }

  void _initializeRecent() {
    try {
      _recentSearchBox = Hive.box<String>('recent_searches');
    } catch (e) {
      // Box already open or not initialized yet
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _isSearching = _searchQuery.isNotEmpty;
    });
    _applyFilters();
  }

  void _selectKeyword(String keyword) {
    setState(() {
      _searchController.text = keyword;
      _saveRecentSearch(keyword);
    });
  }

  void _saveRecentSearch(String query) {
    if (query.isEmpty || _recentSearchBox == null) return;
    try {
      final recent = _recentSearchBox!.get('searches', defaultValue: '')!;
      final searches = recent.isEmpty ? [] : recent.split(',');

      searches.remove(query);
      searches.insert(0, query);

      if (searches.length > 6) {
        searches.removeRange(6, searches.length);
      }

      _recentSearchBox!.put('searches', searches.join(','));
    } catch (e) {
      // Ignore errors
    }
  }

  List<String> _getRecentSearches() {
    if (_recentSearchBox == null) return [];
    try {
      final recent = _recentSearchBox!.get('searches', defaultValue: '')!;
      if (recent.isEmpty) return [];
      return recent.split(',').where((s) => s.isNotEmpty).take(6).toList();
    } catch (e) {
      return [];
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchFocusNode.requestFocus();
    });
    _applyFilters();
  }

  Future<void> _preloadAllProducts(List<StoreEntity> stores) async {
    _loadingAllProducts = true;
    final notifier = ref.read(storesProvider.notifier);
    final collected = <ProductEntity>[];

    for (final store in stores) {
      try {
        await notifier.loadProductsByStore(store.storeId);
        final products = ref.read(storesProvider).products;
        if (products.isNotEmpty) {
          collected.addAll(products);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _allProducts = collected;
        _loadingAllProducts = false;
      });
      _applyFilters();
    }
  }

  void _refreshHintPool(StoresState state) {
    final pool = <String>{};
    for (final s in state.stores) {
      if (s.name.isNotEmpty) pool.add(s.name);
      if ((s.description ?? '').isNotEmpty) pool.add(s.description!);
    }
    final products = _allProducts.isNotEmpty ? _allProducts : state.products;
    for (final p in products) {
      if (p.nameEn.isNotEmpty) pool.add(p.nameEn);
      if ((p.descriptionEn ?? '').isNotEmpty) pool.add(p.descriptionEn!);
    }
    if (pool.isEmpty) {
      pool.add(AppLocalizations.of(context)!.search);
    }
    setState(() {
      _hintPool = pool.toList();
      _hintIndex = 0;
      _currentHint = _hintPool.first;
    });
  }

  void _startHintRotation() {
    _hintTimer?.cancel();
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _hintPool.isEmpty) return;
      setState(() {
        _hintIndex = (_hintIndex + 1) % _hintPool.length;
        _currentHint = _hintPool[_hintIndex];
      });
    });
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredStores = [];
        _filteredProducts = [];
        _filteredOrders = [];
      });
      return;
    }

    final storesState = ref.read(storesProvider);
    final ordersState = ref.read(ordersProvider);
    final productsPool =
        _allProducts.isNotEmpty ? _allProducts : storesState.products;

    final filteredStores = storesState.stores.where((store) {
      final nameMatch = store.name.toLowerCase().contains(query);
      final deliveryMatch =
          (store.estimatedDeliveryTime ?? '').toLowerCase().contains(query);
      return nameMatch || deliveryMatch;
    }).toList();

    final filteredProducts = productsPool.where((product) {
      final nameMatch = product.nameEn.toLowerCase().contains(query);
      final descriptionMatch =
          (product.descriptionEn ?? '').toLowerCase().contains(query);
      return nameMatch || descriptionMatch;
    }).toList();

    final allOrders = [
      ...ordersState.inProgressOrders,
      ...ordersState.completedOrders,
    ];
    final filteredOrders = allOrders.where((order) {
      final storeMatch = (order.storeName ?? '').toLowerCase().contains(query);
      final statusMatch = order.status.toLowerCase().contains(query);
      final numberMatch = order.orderNumber.toLowerCase().contains(query);
      return storeMatch || statusMatch || numberMatch;
    }).toList();

    setState(() {
      _filteredStores = filteredStores;
      _filteredProducts = filteredProducts;
      _filteredOrders = filteredOrders;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _hintTimer?.cancel();
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(storesProvider);
    final recentSearches = _getRecentSearches();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.search,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    
                    duration: const Duration(milliseconds: 250),
                    child: TextField(
                      key: ValueKey(_currentHint),
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: _currentHint,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Searches (hide when searching)
                if (!_isSearching && recentSearches.isNotEmpty) ...[
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recentSearches.map((keyword) {
                      return GestureDetector(
                        onTap: () => _selectKeyword(keyword),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            keyword,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Popular Searches Section
                if (!_isSearching) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.popularSearches,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.burgers,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.burgers),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.coffee,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.coffee),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.indian,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.indian),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.grill,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.grill),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.cakes,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.cakes),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.salads,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.salads),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.pizza,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.pizza),
                      ),
                      _SearchPillButton(
                        text: AppLocalizations.of(context)!.friedChicken,
                        onTap: () => _selectKeyword(AppLocalizations.of(context)!.friedChicken),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],

                // Popular Brands Section
                if (!_isSearching) ...[
                  Text(
                    '${AppLocalizations.of(context)!.popularBrands} 🔥',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        storesState.stores.length > 6
                            ? 6
                            : storesState.stores.length,
                        (index) {
                          final store = storesState.stores[index];
                            return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                              ref.read(storesProvider.notifier).selectStore(store);
                              context.pushNamed(
                                'store-details',
                                pathParameters: {'storeId': store.storeId.toString()},
                                extra: store,
                              );
                              },
                              child: _BrandLogo(store: store),
                            ),
                            );
                        },
                      ),
                    ),
                  ),
                ],

                // Search Results or Suggestions
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: _isSearching
                      ? _buildSearchResults(storesState.stores)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<StoreEntity> allStores) {
    final hasResults =
        _filteredStores.isNotEmpty ||
        _filteredOrders.isNotEmpty ||
        _filteredProducts.isNotEmpty;

    if (!hasResults) {
      return Center(
        key: const ValueKey('no-results'),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noResultsFound,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      key: const ValueKey('search-results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Orders Results
        if (_filteredOrders.isNotEmpty) ...[
          Text(
            '${AppLocalizations.of(context)!.orders} (${_filteredOrders.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._filteredOrders.map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOrderItem(order),
            );
          }),
          const SizedBox(height: 20),
        ],

        // Products Results
        if (_filteredProducts.isNotEmpty) ...[
          Text(
            '${AppLocalizations.of(context)!.products} (${_filteredProducts.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._filteredProducts.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductItem(product),
            );
          }),
          const SizedBox(height: 20),
        ],

        // Stores Results
        if (_filteredStores.isNotEmpty) ...[
          Text(
            '${AppLocalizations.of(context)!.restaurants} (${_filteredStores.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ..._filteredStores.map((store) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildStoreItem(store),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildStoreItem(StoreEntity store) {
    return GestureDetector(
      onTap: () {
        ref.read(storesProvider.notifier).selectStore(store);
        context.pushNamed(
          'store-details',
          pathParameters: {'storeId': store.storeId.toString()},
          extra: store,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Store Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: store.logoUrl != null
                    ? Image.network(
                        ImageUrlHelper.toFullUrl(store.logoUrl) ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.restaurant,
                            color: Colors.grey.shade400,
                            size: 30,
                          );
                        },
                      )
                    : Icon(
                        Icons.restaurant,
                        color: Colors.grey.shade400,
                        size: 30,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        (store.ratingAvg ?? 0).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        store.estimatedDeliveryTime ?? AppLocalizations.of(context)!.min30,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
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

  Widget _buildOrderItem(OrderEntity order) {
    // Helper function to get status color and icon
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
        case 'delivered':
          return Colors.green;
        case 'pending':
        case 'processing':
          return Colors.orange;
        case 'cancelled':
        case 'rejected':
          return Colors.red;
        case 'in delivery':
        case 'shipped':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    IconData getStatusIcon(String status) {
      switch (status.toLowerCase()) {
        case 'completed':
        case 'delivered':
          return Icons.check_circle;
        case 'pending':
        case 'processing':
          return Icons.schedule;
        case 'cancelled':
        case 'rejected':
          return Icons.cancel;
        case 'in delivery':
        case 'shipped':
          return Icons.local_shipping;
        default:
          return Icons.info;
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate to order details if needed
        // Navigator.push(context, MaterialPageRoute(...));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getStatusIcon(order.status),
                        size: 12,
                        color: getStatusColor(order.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Amount and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref
                      .read(countryCurrencyProvider.notifier)
                      .formatConvertedPriceWithSymbolFromUsd(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF03833d),
                  ),
                ),
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return AppLocalizations.of(context)!.unknown;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppLocalizations.of(context)!.today;
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${AppLocalizations.of(context)!.daysAgo}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildProductItem(ProductEntity product) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'product',
          pathParameters: {'productId': product.productId.toString()},
          extra: product,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl != null
                    ? Image.network(
                        ImageUrlHelper.toFullUrl(product.imageUrl) ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fastfood,
                            color: Colors.grey.shade400,
                            size: 30,
                          );
                        },
                      )
                    : Icon(Icons.fastfood, color: Colors.grey.shade400, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameEn,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.descriptionEn != null &&
                      product.descriptionEn!.isNotEmpty)
                    Text(
                      product.descriptionEn!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref
                            .read(countryCurrencyProvider.notifier)
                            .formatConvertedPriceWithSymbolFromUsd(
                              product.price,
                            ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.isAvailable
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.isAvailable
                              ? AppLocalizations.of(context)!.available
                              : AppLocalizations.of(context)!.unavailable,
                          style: TextStyle(
                            fontSize: 11,
                            color: product.isAvailable
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

class _SearchPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SearchPillButton({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final StoreEntity store;

  const _BrandLogo({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: store.logoUrl != null
            ? Image.network(
                ImageUrlHelper.toFullUrl(store.logoUrl) ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey.shade400,
                      size: 35,
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.restaurant,
                  color: Colors.grey.shade400,
                  size: 35,
                ),
              ),
      ),
    );
  }
}
