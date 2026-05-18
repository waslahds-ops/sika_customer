import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/store_entities.dart';

/// Provides offers for a Sika Fresh store
final storeOffersProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, storeId) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final result = await apiService.getStoreOffers(storeId);
    final offers = result['data'] as List? ?? [];
    return offers.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    print('❌ Error fetching offers: $e');
    return [];
  }
});

/// Provides buy-again (previous order items) for a Sika Fresh store
final storeBuyAgainProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, storeId) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    final result = await apiService.getStoreBuyAgain(storeId);
    final items = result['data'] as List? ?? [];
    return items.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    print('⚠️ Buy Again not yet available: $e');
    return [];
  }
});

class SikaFreshStoreShell extends ConsumerStatefulWidget {
  final StoreEntity store;

  const SikaFreshStoreShell({super.key, required this.store});

  @override
  ConsumerState<SikaFreshStoreShell> createState() => _SikaFreshStoreShellState();
}

class _SikaFreshStoreShellState extends ConsumerState<SikaFreshStoreShell> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _containerOpacity = 1.0;
  bool _isAppBarExpanded = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    double newOpacity = 1.0;
    if (scrollOffset > 120) {
      newOpacity = 0.0;
    } else if (scrollOffset > 80) {
      newOpacity = 1.0 - ((scrollOffset - 80) / 40);
    }

    setState(() {
      _containerOpacity = newOpacity;
      if (scrollOffset > 120 && _isAppBarExpanded) {
        _isAppBarExpanded = false;
      } else if (scrollOffset <= 120 && !_isAppBarExpanded) {
        _isAppBarExpanded = true;
      }
    });
  }

  Future<Map<String, dynamic>> _fetchAisles() async {
    final apiService = ref.read(apiServiceProvider);
    final result = await apiService.getStoreAisles(widget.store.storeId);
    return result;
  }

  double _calculateHeaderTop(double initialTop) {
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    if (scrollOffset >= initialTop) return 56.0;
    return initialTop - scrollOffset;
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _isAppBarExpanded ? Colors.white : Colors.black.withOpacity(0.3),
      elevation: 0,
      title: _isAppBarExpanded ? null : Text(widget.store.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
        child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: widget.store.logoUrl != null && widget.store.logoUrl!.isNotEmpty
            ? Image.network(ImageUrlHelper.toFullUrl(widget.store.logoUrl) ?? '', fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: Icon(Icons.restaurant, size: 80, color: Colors.grey[400])))
            : Container(color: Colors.grey[200], child: Icon(Icons.restaurant, size: 80, color: Colors.grey[400])),
      ),
    );
  }

  Widget _buildResponsiveStoreHeader(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 360;
    final containerPadding = isSmallScreen ? 12.0 : 16.0;
    final logoSize = isSmallScreen ? 36.0 : 40.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(color: const Color(0xFFFBFBFB), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: widget.store.logoUrl != null && widget.store.logoUrl!.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(ImageUrlHelper.toFullUrl(widget.store.logoUrl) ?? '', fit: BoxFit.cover))
                    : Center(child: Text(widget.store.name[0].toUpperCase(), style: TextStyle(fontSize: isSmallScreen ? 16 : 20, fontWeight: FontWeight.bold, color: Colors.black))),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(child: Text(widget.store.name, style: TextStyle(fontSize: isSmallScreen ? 14 : 18, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    final offersAsync = ref.watch(storeOffersProvider(widget.store.storeId));

    return offersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading offers')),
      data: (offers) {
        if (offers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Special Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Check back soon', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            final name = offer['name'] ?? 'Offer';
            final price = offer['price'] ?? 0;
            final originalPrice = offer['original_price'] ?? price;
            final imageUrl = offer['image_url'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: imageUrl != null && imageUrl.toString().isNotEmpty
                          ? Image.network(ImageUrlHelper.toFullUrl(imageUrl.toString()) ?? '', width: 100, height: 100, fit: BoxFit.cover)
                          : Container(width: 100, height: 100, color: Colors.grey[200], child: Icon(Icons.shopping_bag, color: Colors.grey[400])),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('\$$price', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                                const SizedBox(width: 8),
                                if (originalPrice > price)
                                  Text('\$$originalPrice', style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.lineThrough)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () {},
                        backgroundColor: Colors.teal,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBuyAgainTab() {
    final buyAgainAsync = ref.watch(storeBuyAgainProvider(widget.store.storeId));

    return buyAgainAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildBuyAgainEmpty(),
      data: (items) {
        if (items.isEmpty) {
          return _buildBuyAgainEmpty();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final name = item['name'] ?? 'Item';
            final price = item['price'] ?? 0;
            final imageUrl = item['image_url'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      child: imageUrl != null && imageUrl.toString().isNotEmpty
                          ? Image.network(ImageUrlHelper.toFullUrl(imageUrl.toString()) ?? '', width: 100, height: 100, fit: BoxFit.cover)
                          : Container(width: 100, height: 100, color: Colors.grey[200], child: Icon(Icons.shopping_bag, color: Colors.grey[400])),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('\$$price', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () {},
                        backgroundColor: Colors.teal,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBuyAgainEmpty() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Reordering made easy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Items you order will show up here', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: () => setState(() => _selectedTabIndex = 0), child: const Text('Browse aisles')),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: [
          BottomNavigationBarItem(icon: Image.asset('assets/icons/shop.png', width: 24, height: 24), label: AppLocalizations.of(context)!.shop),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/aisles.png', width: 24, height: 24), label: AppLocalizations.of(context)!.aisles),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/offers.png', width: 24, height: 24), label: AppLocalizations.of(context)!.offers),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/buy_again.png', width: 24, height: 24), label: AppLocalizations.of(context)!.buyAgain),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(storesProvider);
    final _products = storesState.products;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFFBFBFB), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Image.asset('assets/icons/rewards.png', width: 12, height: 12),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.rewards, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFFBFBFB), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Image.asset('assets/icons/points.png', width: 12, height: 12),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.earnPoints, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.black)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search,
                          prefixIcon: Padding(padding: const EdgeInsets.all(10.0), child: SvgPicture.asset('assets/icons/search.svg', color: Colors.black)),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Tab content
              SliverFillRemaining(
                child: _selectedTabIndex == 0
                    ? _buildShopTab()
                    : _selectedTabIndex == 1
                        ? _buildAislesTab()
                        : _selectedTabIndex == 2
                            ? _buildOffersTab()
                            : _buildBuyAgainTab(),
              ),
            ],
          ),
          Positioned(top: _calculateHeaderTop(190), left: 16, right: 16, child: Opacity(opacity: _containerOpacity, child: LayoutBuilder(builder: (context, constraints) => _buildResponsiveStoreHeader(constraints)))),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildShopTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAisles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text(AppLocalizations.of(context)!.noProductsAvailableAtThisTime));

        final aislesData = snapshot.data?['data'] as List? ?? [];
        final aisles = aislesData.map((e) => e as Map<String, dynamic>).toList();

        if (aisles.isEmpty) return Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(AppLocalizations.of(context)!.noProductsAvailableAtThisTime)));

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
            itemCount: aisles.length,
            itemBuilder: (context, index) {
              final aisle = aisles[index];
              final aisleName = aisle['name'] ?? 'Unknown';
              final productCount = aisle['product_count'] ?? 0;
              final imageUrl = aisle['image_url'];

              return GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: imageUrl != null && imageUrl.toString().isNotEmpty
                              ? Image.network(ImageUrlHelper.toFullUrl(imageUrl.toString()) ?? '', width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: Icon(Icons.shopping_cart, color: Colors.grey[400])))
                              : Container(color: Colors.grey[200], child: Icon(Icons.shopping_cart, color: Colors.grey[400])),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(aisleName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text('$productCount items', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
      },
    );
  }

  Widget _buildAislesTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAisles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text(AppLocalizations.of(context)!.noProductsAvailableAtThisTime));

        final aislesData = snapshot.data?['data'] as List? ?? [];
        final aisles = aislesData.map((e) => e as Map<String, dynamic>).toList();

        if (aisles.isEmpty) return Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(AppLocalizations.of(context)!.noProductsAvailableAtThisTime)));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: aisles.length,
          itemBuilder: (context, index) {
            final aisle = aisles[index];
            final aisleName = aisle['name'] ?? 'Unknown';
            final productCount = aisle['product_count'] ?? 0;
            final imageUrl = aisle['image_url'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        child: imageUrl != null && imageUrl.toString().isNotEmpty
                            ? Image.network(ImageUrlHelper.toFullUrl(imageUrl.toString()) ?? '', width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 100, height: 100, color: Colors.grey[200], child: Icon(Icons.shopping_cart, color: Colors.grey[400])))
                            : Container(width: 100, height: 100, color: Colors.grey[200], child: Icon(Icons.shopping_cart, color: Colors.grey[400])),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(aisleName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              const SizedBox(height: 4),
                              Text('$productCount products', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
