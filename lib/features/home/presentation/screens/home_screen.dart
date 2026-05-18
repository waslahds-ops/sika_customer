import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sika_customer/features/home/presentation/screens/main_navigation_screen.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';

import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/promotion_provider.dart';
import '../../../../core/providers/voucher_provider.dart';
import '../../../../core/providers/currency_provider.dart' show currencyProvider, formatPrice;
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/widgets/promotional_popup_dialog.dart';
import '../../../../core/widgets/merchant_voucher_dialog.dart';
import '../../../../injection_container.dart';
import '../../../stores/domain/entities/store_entities.dart';
import '../../../stores/presentation/providers/stores_provider.dart';
import '../../../stores/presentation/screens/search_screen.dart';
import 'filter_chip_widget.dart';
import '../widgets/collapsible_home_header.dart';
import '../widgets/popular_brands_section.dart';
import '../widgets/food_categories_section.dart';
import '../widgets/flash_deals_section.dart';
import '../widgets/home_shimmer_loader.dart';
import '../providers/voucher_products_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static String _persistedAddress = 'Locating...';
  String _currentAddress = _persistedAddress;
  bool _isLoadingLocation = false;
  bool _isRefreshing = false;
  double? _currentLatitude;
  double? _currentLongitude;

  // Filter states
  bool _freeDeliveryFilter = false;
  bool _offersFilter = false;
  bool _newFilter = false;
  bool _topRatedFilter = false;
  String? _selectedSortOption;

  // Distance-based store categories
  static const double NEARBY_DISTANCE_KM = 50.0;
  static const double MAX_DELIVERY_DISTANCE_KM = 1160.0;

  // Dynamic search hint
  String _searchHint = "McDonald's";
  Timer? _searchHintTimer;
  int _hintCycle = 0;

  // Scroll controller for collapsible header
  final ScrollController _scrollController = ScrollController();
  bool _showSearchBar = false;
  bool _showScrollToTop = false;
  bool _authListenerRegistered = false;
  
  // Pagination for "Nearby You" section
  int _nearbyStoresDisplayed = 5; // Show 5 stores initially
  static const int STORES_PER_PAGE = 5;

  @override
  void initState() {
    super.initState();
    // Only fetch location if not already set
    if (_persistedAddress == 'Locating...') {
      setState(() {
        _isLoadingLocation = true;
      });
      _getCurrentLocation();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSearchHintRotation();
    });
    // Load stores and categories data after build is complete to avoid provider modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final storesNotifier = ref.read(storesProvider.notifier);
      storesNotifier.loadCategories();
      storesNotifier.loadStores(
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        excludeSpecialCategories: true,
      );
      // Trigger loading of popular stores, promotions, and vouchers
      ref.read(popularStoresProvider);
      ref.read(promotionsProvider);
      ref.read(popupVoucherProvider);  // Preload voucher
    });

    // Prepare popup state synchronously to avoid using `ref` inside async callbacks
    final appStateBox = Hive.box('appStateBox');
    final hasShownPopups =
        appStateBox.get('popupsShown', defaultValue: false) ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!hasShownPopups) {
        // Decide which popup to show based on backend promotions and user state.
        _decideAndShowPopup();
        // Mark popups as shown for this app session
        appStateBox.put('popupsShown', true);
      } else {
        // For subsequent app sessions, still attempt to show merchant media
        if (mounted) _showMerchantVoucherPopup();
      }
    });

    // NOTE: auth listener registered from build() to satisfy Riverpod debug checks

    // Listen to scroll changes to show/hide search bar
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 100;
      if (shouldShow != _showSearchBar) {
        setState(() {
          _showSearchBar = shouldShow;
        });
      }

      final shouldShowScrollTop = _scrollController.offset > 1000;
      if (shouldShowScrollTop != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShowScrollTop;
        });
      }
    });
  }

  ProductEntity _voucherProductToProductEntity(VoucherProduct product) {
    final price = double.tryParse(product.finalPrice) ?? 0;
    return ProductEntity(
      productId: product.productId,
      storeId: product.storeId,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      descriptionAr: product.voucherNameAr,
      descriptionEn: product.voucherNameEn,
      price: price,
      imageUrl: product.imageUrl,
      category: null,
      isAvailable: product.isAvailable,
      preparationTime: '${product.estimatedDeliveryTime}',
    );
  }

  /// Decide which popup to show. Priority:
  /// 1) If API has a popup voucher -> show voucher popup
  /// 2) If backend has a promotion with merchant media (imageUrl) -> show merchant voucher popup
  /// 3) Else if unauthenticated first-time user -> show new-user voucher popup
  /// 4) Else if backend has a promotion (no image) -> show standard promotional popup
  Future<void> _decideAndShowPopup() async {
    if (!mounted) return;

    try {
      // First, try to fetch and show API voucher popup
      final voucher = await ref.read(popupVoucherProvider.future);
      if (voucher != null && mounted) {
        _showAPIVoucherPopup(voucher);
        return;
      }

      // Get promotion notifier synchronously (safe) then load next promotion
      final promotionNotifier = ref.read(currentPromotionProvider.notifier);
      await promotionNotifier.loadNextPromotion();

      if (!mounted) return;

      final promotion = ref.read(currentPromotionProvider);
      final appStateBox = Hive.box('appStateBox');
      final hasSeenNewUserVoucher =
          appStateBox.get('hasSeenNewUserVoucher', defaultValue: false) ??
          false;
      final isAuth = ref.read(authProvider).isAuthenticated;

      // If backend provided merchant media, show it and stop
      if (promotion != null &&
          promotion.imageUrl != null &&
          promotion.imageUrl!.isNotEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => MerchantVoucherDialog(
              imageUrl: promotion.imageUrl,
              title: promotion.title,
              subtitle: promotion.description,
              onClose: () => Navigator.of(context).pop(),
              onAction: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  context.push('/vouchers');
                });
              },
            ),
          );
        }
        return;
      }

      // If no merchant media and user is unauthenticated and hasn't seen new-user vouchers
      if (!isAuth && !hasSeenNewUserVoucher) {
        if (mounted) _showNewUserVoucherPopup();
        appStateBox.put('hasSeenNewUserVoucher', true);
        return;
      }

      // Fallback: if there's any promotion, show standard promotional popup
      if (promotion != null) {
        await _showPromotionalPopups();
        return;
      }
    } catch (e) {
      debugPrint('Error deciding popup: $e');
    }
  }

  Future<void> _claimNewUserVouchers() async {
    if (!mounted) return;
    try {
      // Trigger a refresh of the customer's promo codes (backend is expected
      // to have created/assigned new-user vouchers on login/registration).
      await ref.read(getCustomerPromoCodesUseCaseProvider)();

      // Navigate to vouchers screen to show the newly-assigned vouchers
      if (mounted) context.push('/vouchers');
    } catch (e) {
      debugPrint('Error claiming new user vouchers: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to fetch vouchers.')));
      }
    }
  }

  void _showNewUserVoucherPopup() {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Vouchers',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        final width = MediaQuery.of(context).size.width * 0.88;
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: Center(
                child: Material(
                  color: AppPallete.gold,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: width,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFDB714),
                              const Color(0xFFFFD54F),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildAnimatedContent(animation),
                      ),
                      // Close button with rotation animation
                      Positioned(
                        top: -12,
                        right: -12,
                        child: RotationTransition(
                          turns: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: const Interval(
                                0.5,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(0xff1C1C1E),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPromotionalPopups() async {
    if (!mounted) return;

    try {
      // Fetch unshown promotions
      final promotionNotifier = ref.read(currentPromotionProvider.notifier);
      await promotionNotifier.loadNextPromotion();

      final promotion = ref.read(currentPromotionProvider);
      if (promotion != null) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => PromotionalPopupDialog(
            promotion: promotion,
            onClose: () {
              Navigator.pop(context);
              // Mark as shown and show next one if available
              Future.delayed(const Duration(milliseconds: 500), () {
                _showNextPromotionPopup();
              });
            },
            onAction: () {
              // Handle action - could navigate to vouchers or deals page
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 500), () {
                context.push('/vouchers');
              });
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing promotional popup: $e');
    }
  }

  Future<void> _showNextPromotionPopup() async {
    if (!mounted) return;

    try {
      final promotion = ref.read(currentPromotionProvider);
      if (promotion != null) {
        // Mark current promotion as shown
        await ref
            .read(currentPromotionProvider.notifier)
            .markPromotionAsShown(promotion.id);

        // Load next promotion
        await ref.read(currentPromotionProvider.notifier).loadNextPromotion();

        final nextPromotion = ref.read(currentPromotionProvider);
        if (nextPromotion != null && mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => PromotionalPopupDialog(
              promotion: nextPromotion,
              onClose: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showNextPromotionPopup();
                });
              },
              onAction: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 500), () {
                  context.push('/vouchers');
                });
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error showing next promotional popup: $e');
    }
  }

  Future<void> _showMerchantVoucherPopup() async {
    if (!mounted) return;

    try {
      // Attempt to load a promotion that may contain merchant media
      final promotionNotifier = ref.read(currentPromotionProvider.notifier);
      await promotionNotifier.loadNextPromotion();

      final promotion = ref.read(currentPromotionProvider);
      if (promotion != null &&
          promotion.imageUrl != null &&
          promotion.imageUrl!.isNotEmpty) {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => MerchantVoucherDialog(
            imageUrl: promotion.imageUrl,
            title: promotion.title,
            subtitle: promotion.description,
            onClose: () => Navigator.of(context).pop(),
            onAction: () {
              // navigate to vouchers or merchant landing
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                context.push('/vouchers');
              });
            },
          ),
        );
      } else {
        // No merchant media: fallback to standard promotional popup flow
        await _showPromotionalPopups();
      }
    } catch (e) {
      debugPrint('Error showing merchant voucher popup: $e');
    }
  }

  /// Show API Voucher Popup
  void _showAPIVoucherPopup(dynamic voucher) {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Voucher',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            ),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Close button
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Voucher Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              voucher['image_url'] ?? '',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Voucher Name
                          Text(
                            voucher['name_en'] ?? 'Special Offer',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          
                          // Voucher Description
                          Text(
                            voucher['description_en'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // Voucher Details Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'CODE: ${voucher['code'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  voucher['discount_type'] == 'percentage'
                                      ? '${voucher['discount_value'] ?? 0}% OFF'
                                      : '${(voucher['discount_value'] ?? 0).toStringAsFixed(2)} EGP OFF',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push('/vouchers');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.primaryYellow,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Use This Voucher',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContent(Animation<double> animation) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gift Icon with bounce animation
        ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Color(0xFFFDB714),
                  size: 48,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Title with fade animation
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
            ),
          ),
          child: const Text(
            '🎉 Congratulations!',
            style: TextStyle(
              color: Color(0xff1C1C1E),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle with fade animation
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.45, 0.95, curve: Curves.easeIn),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.newUserWelcomeVouchers.toUpperCase(),
            style: const TextStyle(
              color: Color(0xff48484A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Total Worth with scale animation
        ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Worth',
                  style: TextStyle(
                    color: Color(0xff48484A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '\$10.00',
                  style: TextStyle(
                    color: Color(0xff1C1C1E),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Coupon Tiles with staggered animation
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
            ),
          ),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
                  ),
                ),
            child: Container(
              child: Column(
                children: [
                  _buildEnhancedCouponTile(
                    '🎁 1st Order',
                    '50% Off',
                    'New User',
                  ),
                  const SizedBox(height: 10),
                  _buildEnhancedCouponTile(
                    '🛍️ Any Order',
                    '30% Off x3',
                    'New User',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // CTA Button with scale animation
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final appStateBox = Hive.box('appStateBox');
                final isAuth = ref.read(authProvider).isAuthenticated;

                if (!isAuth) {
                  // Mark that we want to claim vouchers after login
                  appStateBox.put('pendingNewUserVoucherClaim', true);
                  // Send user to login; after successful login listener will handle claiming
                  context.push('/login');
                  return;
                }

                // Already authenticated: attempt to claim (refresh) and go to vouchers
                await _claimNewUserVouchers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1C1C1E),
                foregroundColor: const Color(0xFFFDB714),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 8,
              ),
              child: const Text(
                'Claim Vouchers Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Secondary button with fade animation
        FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff48484A),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCouponTile(
    String leftLabel,
    String mainLabel,
    String tag,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDB714).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDB714), width: 1),
            ),
            child: Text(
              leftLabel,
              style: const TextStyle(
                color: Color(0xff1C1C1E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mainLabel,
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 10),
          Text(
            tag,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchHintTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Permission denied';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];

        setState(() {
          // Try to get city name from different fields, ensuring not null
          String cityName = 'Current Location';

          if (place.locality != null && place.locality!.isNotEmpty) {
            cityName = place.locality!;
          } else if (place.subAdministrativeArea != null &&
              place.subAdministrativeArea!.isNotEmpty) {
            cityName = place.subAdministrativeArea!;
          } else if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            cityName = place.administrativeArea!;
          } else if (place.subLocality != null &&
              place.subLocality!.isNotEmpty) {
            cityName = place.subLocality!;
          } else if (place.country != null && place.country!.isNotEmpty) {
            cityName = place.country!;
          }

          _currentAddress = cityName;
          _persistedAddress = cityName;
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _currentAddress = 'Current Location';
          _persistedAddress = 'Current Location';
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Current Location';
        _persistedAddress = 'Current Location';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _showLocationBottomSheet() async {
    await _getCurrentLocation();
    final currentLatitude = _currentLatitude ?? 33.8547;
    final currentLongitude = _currentLongitude ?? 35.8623;
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationBottomSheet(
        currentAddress: _currentAddress,
        latitude: currentLatitude,
        longitude: currentLongitude,
        onConfirm: (LatLng newLocation, String newAddress) {
          setState(() {
            _currentLatitude = newLocation.latitude;
            _currentLongitude = newLocation.longitude;
            _currentAddress = newAddress;
          });
          // Reload stores with new location
          ref
              .read(storesProvider.notifier)
              .loadStores(
                latitude: _currentLatitude,
                longitude: _currentLongitude,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    print('🔄 Refreshing home screen...');
    setState(() {
      _isRefreshing = true;
    });
    try {
      // Reload categories and stores with current location
      await ref.read(storesProvider.notifier).loadCategories();
      await ref
          .read(storesProvider.notifier)
          .loadStores(latitude: _currentLatitude, longitude: _currentLongitude);
      print('✅ Home screen refreshed');
    } catch (e) {
      print('❌ Refresh error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToRefresh}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show shimmer loader while refreshing
    if (_isRefreshing) {
      return const HomeShimmerLoader();
    }

    // Register auth listener from build() so Riverpod debug checks are satisfied
    if (!_authListenerRegistered) {
      _authListenerRegistered = true;
      ref.listen(authProvider, (previous, next) {
        if (!mounted) return;
        try {
          final appStateBox = Hive.box('appStateBox');
          final pending =
              appStateBox.get(
                'pendingNewUserVoucherClaim',
                defaultValue: false,
              ) ??
              false;
          if (pending && next.isAuthenticated) {
            appStateBox.put('pendingNewUserVoucherClaim', false);
            final getPromosUseCase = ref.read(
              getCustomerPromoCodesUseCaseProvider,
            );
            Future.microtask(() async {
              try {
                await getPromosUseCase();
              } catch (_) {}
              if (mounted) context.push('/vouchers');
            });
          }
        } catch (e) {
          debugPrint('Error in auth listener: $e');
        }
      });
    }

    return Scaffold(
      backgroundColor: AppPallete.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
            // Collapsible Header with search - collapses but stays pinned
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: Color(0xFFFBEF53),
              expandedHeight: 280,
              elevation: 0,
              scrolledUnderElevation: 2,
              toolbarHeight: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: CollapsibleHomeHeader(
                  currentAddress: _currentAddress,
                  isLoadingLocation: _isLoadingLocation,
                  searchHint: _searchHint,
                  scrollController: _scrollController,
                  showLoginBanner: !ref.watch(authProvider).isAuthenticated,
                  shouldHideSearchBar: _showSearchBar,
                  onLoginTap: () {
                    // navigate to login
                    context.push('/login');
                  },
                  onLocationTap: () async {
                    await _showLocationBottomSheet();
                  },
                  onSearchTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SearchScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 0.1);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;
                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              var fadeTween = Tween(begin: 0.0, end: 1.0);
                              var fadeAnimation = animation.drive(fadeTween);
                              return FadeTransition(
                                opacity: fadeAnimation,
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                ),
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(_showSearchBar ? 50 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: _showSearchBar ? 50 : 0,
                  color: AppPallete.white,
                  child: _showSearchBar
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                          child: _buildSearchBar()
                        )
                      : null,
                ),
              ),
            ),

            // Categories BEFORE filter chips
            SliverList(
                delegate: SliverChildListDelegate([
                // Food Categories
                FoodCategoriesSection(
                  categories: ref.watch(storesProvider).categories,
                  selectedCategoryId: ref.watch(storesProvider).selectedCategory?.categoryId,
                  onCategoryTap: (category) {
                  debugPrint('🔵 Category tapped: ${category.nameEn}');
                  final lower = category.nameEn.toLowerCase();
                  if (lower.contains('booking')) {
                    context.push('/booking');
                    return;
                  }
                  if (lower.contains('butler') || lower.contains('driver')) {
                    ref.read(navigationIndexProvider.notifier).state = 2;
                    return;
                  }
                  final current = ref.read(storesProvider).selectedCategory;
                  // Only select if it's different from current selection
                  if (current == null || current.categoryId != category.categoryId) {
                    debugPrint('🟡 Setting category: ${category.nameEn}');
                    ref.read(storesProvider.notifier).selectCategory(category);
                    setState(() {});
                  }
                  },
                ),
                // Banner placeholder (image will be provided by backend later)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                  child: SizedBox(
                  height: 120,
                  child: Image.asset(
                    'assets/images/test.png',
                    fit: BoxFit.fill,
                  ),
                  ),
                ),
             ]),
            ),

            // Previously pinned filter chips — moved below Nearby section
            
            // Content - Everything scrolls together (first chunk up to Nearby)
            SliverList(
              delegate: SliverChildListDelegate([
                // Compact Banner Section
               
                // Offers for you Section (includes both promotions and voucher products)
                _buildOffersForYouSection(),
                // Popular Brands (moved after offers) - Filter by selected category
                PopularBrandsSection(
                  selectedCategory: ref.watch(storesProvider).selectedCategory,
                  onStoreTap: (store) {
                    ref.read(storesProvider.notifier).selectStore(store);
                  },
                ),
                const SizedBox(height: 12),
                // Flash Deals Section - Filter by selected category
                FlashDealsSection(
                  categoryId: ref.watch(storesProvider).selectedCategory?.categoryId,
                ),
                const SizedBox(height: 12),
                // Gathering Offers Section
                _buildGatheringOffersSection(),

                // Nearby You - Stores within 50km (falls back to all stores when empty)
              ]),
            ),

            // Nearby You Title and Filter Chips
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.nearbyYou,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                      Divider(color: Colors.grey.withValues(alpha: 0.3), thickness: 1),
                    ],
                  ),
                ),
              ]),
            ),

            // Pinned filter header for Nearby You section
            SliverPersistentHeader(
              pinned: true,
              delegate: _NearbyFilterChipsHeaderDelegate(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                            _offersFilter = !_offersFilter; 
                            });
                          },
                          child: FilterChipWidget(
                            label: AppLocalizations.of(context)!.offers,
                            icon: Icons.sort,
                            selected: _offersFilter,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _freeDeliveryFilter = !_freeDeliveryFilter;
                            });
                          },
                          child: FilterChipWidget(
                            label: AppLocalizations.of(context)!.freeDelivery,
                            icon: Icons.delivery_dining,
                            selected: _freeDeliveryFilter,
                          ),
                        ),
                        const SizedBox(width: 8),                      
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _topRatedFilter = !_topRatedFilter;
                            });
                          },
                          child: FilterChipWidget(
                            label: AppLocalizations.of(context)!.topRated,
                            icon: Icons.star,
                            selected: _topRatedFilter,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _newFilter = !_newFilter;
                            });
                          },
                          child: FilterChipWidget(
                            label: AppLocalizations.of(context)!.labelNew,
                            icon: Icons.fiber_new,
                            selected: _newFilter,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Nearby You stores content
            SliverList(
              delegate: SliverChildListDelegate([
                _buildTrendyFlavorsSection(),
                const SizedBox(height: 6),
                // Other stores styled like nearby (full-width cards)
                _buildFarStoresSection(),
                const SizedBox(height: 80),
              ]),
            ),
          ],
        ),
      ),
      if (_showScrollToTop)
            Positioned(
              top: MediaQuery.of(context).padding.top + 110,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _scrollToTop,
                  child: Container(
                    width: 140,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.back2Top,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SearchScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 0.1);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  var fadeTween = Tween(begin: 0.0, end: 1.0);
                  var fadeAnimation = animation.drive(fadeTween);
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/search.svg',
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: Text(
                _searchHint,
                key: ValueKey(_searchHint),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildGatheringOffersSection() {
    // Get all products from stores via the stores provider
    // Products would be fetched per store, but not available in StoreEntity
    // For now, showing only if stores exist

    List<ProductEntity> allProducts = [];

    // If we have no products data yet, return empty
    if (allProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter products by price (under 50,000 LBP example)
    final budgetProducts = allProducts.where((p) => p.price < 50000).toList();

    if (budgetProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GATHERING OFFERS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              text: 'Meals up to ',
              style: TextStyle(fontSize: 14, color: AppPallete.textSecondary),
              children: [
                TextSpan(
                  text: '40% off',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppPallete.primaryYellow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Offer cards horizontal scroll with real products
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: budgetProducts.length,
              itemBuilder: (context, index) {
                final product = budgetProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 200,
                    child: _buildOfferCard(
                      price: product.price.toStringAsFixed(2),
                      title: product.nameEn,
                      deliveryTime: product.preparationTime ?? 'N/A',
                      isFreeDelivery: true,
                      discount: AppLocalizations.of(context)!.specialOffer,
                      foodIcon: Icons.restaurant,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startSearchHintRotation() {
    _searchHintTimer?.cancel();
    _updateSearchHint();
    _searchHintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _updateSearchHint();
    });
  }

  // Dynamic search hint method - rotates between brand names and category names
  void _updateSearchHint() {
    if (!mounted) return;

    final storesState = ref.read(storesProvider);
    final stores = storesState.stores;
    final categories = storesState.categories
        .where((c) => c.nameEn.toLowerCase() != 'all')
        .toList();

    _hintCycle++;
    final useStores = _hintCycle % 2 == 0;
    final random = Random(DateTime.now().millisecondsSinceEpoch);

    String newHint = AppLocalizations.of(context)!.startSearching; // fallback

    if (useStores && stores.isNotEmpty) {
      final popularStores =
          stores.where((s) => (s.ratingAvg ?? 0) >= 4.0).toList();
      final sourceStores = popularStores.isNotEmpty ? popularStores : stores;
      final randomStore = sourceStores[random.nextInt(sourceStores.length)];
      newHint = randomStore.name;
    } else if (categories.isNotEmpty) {
      final randomCategory = categories[random.nextInt(categories.length)];
      newHint = randomCategory.nameEn;
    } else if (stores.isNotEmpty) {
      final randomStore = stores[random.nextInt(stores.length)];
      newHint = randomStore.name;
    }

    if (mounted) {
      setState(() {
        _searchHint = newHint;
      });
    }
  }

  Widget _buildOfferCard({
    required String price,
    required String title,
    required String deliveryTime,
    required bool isFreeDelivery,
    required String discount,
    required IconData foodIcon,
  }) {
    return GestureDetector(
      onTap: () {
        // Enable offers filter and navigate to stores with offers
        setState(() {
          _offersFilter = true;
        });
        context.push('/stores');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppPallete.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with discount badge
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFD600), // Sika yellow
                        Color(0xFF00C897), // Sika teal
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            foodIcon,
                            size: 60,
                            color: AppPallete.primaryYellow.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPallete.primaryYellow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 14, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          discount,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Details section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$ $price',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppPallete.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 16,
                        color: AppPallete.primaryYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFreeDelivery
                            ? AppLocalizations.of(context)!.free
                            : AppLocalizations.of(context)!.deliveryFee,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppPallete.primaryYellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        deliveryTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPallete.textSecondary,
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

  Widget _buildOffersForYouSection() {
    // Watch promotions and voucher products from providers
    final promotionsAsync = ref.watch(promotionsProvider);
    final voucherProductsAsync = ref.watch(firstVoucherProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use SVG title asset for "Offers for you" — render large and left-aligned
        SizedBox(
          width: double.infinity,
          child: Image.asset(
            'assets/images/Offers for you.png',
            height: 72,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            alignment: Alignment.centerLeft,
          ),
        ),

        // Show promotion products that specifically have 50% discount
        Builder(builder: (context) {
          // Use the same promotions provider to show 50% items
          return promotionsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (promos) {
              final fifty = promos
                  .where((p) => p.discountPercentage != null && p.discountPercentage! >= 50)
                  .toList();
              if (fifty.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.only(left: 6),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fifty.length,
                  itemBuilder: (context, index) {
                    final promo = fifty[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index == fifty.length - 1 ? 6 : 6),
                      child: SizedBox(
                        width: 120,
                        child: _buildPromoProductCard(context, promo),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }),

        // Show voucher discounted products (50% off) below promotions
        Builder(builder: (context) {
          return voucherProductsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (voucherProducts) {
              // Filter products with 50% or more discount
              final fiftyOffProducts = voucherProducts
                  .where((p) {
                    final discount = double.tryParse(p.discountPercentage) ?? 0;
                    return discount >= 50;
                  })
                  .toList();

              if (fiftyOffProducts.isEmpty) return const SizedBox.shrink();

              return Container(
                color: AppPallete.transparent,
                padding: const EdgeInsets.only(left: 6),
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fiftyOffProducts.length,
                  itemBuilder: (context, index) {
                    final product = fiftyOffProducts[index];
                    final discount = double.tryParse(product.discountPercentage) ?? 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: SizedBox(
                        width: 120,
                        child: _buildVoucherProductCard(context, product, discount),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }),
      ],
    );
  }

  /// Build card for promo products
  Widget _buildPromoProductCard(BuildContext context, dynamic promo) {
    // Existing implementation - kept for backward compatibility
    return const SizedBox.shrink();
  }

  /// Build card for voucher discounted products
  Widget _buildVoucherProductCard(
    BuildContext context,
    VoucherProduct product,
    double discount,
  ) {
    final finalPrice = double.tryParse(product.finalPrice) ?? 0;
    final originalPrice = double.tryParse(product.originalPrice) ?? 0;

    return GestureDetector(
      onTap: () {
        final productEntity = _voucherProductToProductEntity(product);
        context.push(
          '/product/${product.productId}',
          extra: productEntity,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppPallete.transparent,
          borderRadius: BorderRadius.circular(12),
          
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with Discount Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        product.imageUrl.startsWith('http')
                            ? product.imageUrl
                            : 'https://sika.waslah.ai${product.imageUrl}',
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                          );
                        },
                      ),
                    ),
                    // Discount Badge - Bottom Left
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFE80000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${discount.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Product Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Section - Large and Red (with currency)
                        Consumer(
                          builder: (context, ref, _) {
                            final currency = ref.watch(currencyProvider);
                            return SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      formatPrice(finalPrice, currency),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE80000),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Old Price - Small and Strikethrough
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      formatPrice(originalPrice, currency),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        // Product Name
                        Text(
                          product.nameEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        // Delivery Info Row with Icon
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/delivery_icon.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.deliveryFee == 0
                                  ? 'Free'
                                  :'${product.deliveryFee} LBP',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              product.freeDelivery
                                  ? AppLocalizations.of(context)!.freeDelivery
                                  : '${product.estimatedDeliveryTime}m',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: product.freeDelivery
                                    ? Colors.green
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Add to Cart Button - Top Right (on image area only)
            Positioned(
              top: 110,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  // Add to cart logic
                    final isAuthenticated = ref.read(authProvider).isAuthenticated;
                    if (!isAuthenticated) {
                    context.push('/login');
                    return;
                    }
                    // Add to cart logic here (replace with your actual add-to-cart implementation)
                    // Example: ref.read(cartProvider.notifier).addProduct(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to cart'),
                      duration: Duration(seconds: 1),
                    ),
                    );
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.yellow[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(List<StoreEntity> allStores) {
    // When user scrolls near the loading indicator, load more stores
    Future.microtask(() {
      if (_nearbyStoresDisplayed < allStores.length) {
        setState(() {
          _nearbyStoresDisplayed += STORES_PER_PAGE;
          print('🏪 [Nearby You] Loading more stores: $_nearbyStoresDisplayed/${allStores.length}');
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppPallete.primaryYellow),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading more stores...',
              style: TextStyle(
                fontSize: 14,
                color: AppPallete.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildRegistrationPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Registration message
          Text(
            AppLocalizations.of(context)!.registerForMore,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppPallete.primaryYellow,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Blurred placeholder stores (3 cards)
          ...[0, 1, 2].map((index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Blur effect overlay
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        child: Container(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 16),
          
          // Sign up button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.signUp,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTrendyFlavorsSection() {
    // Use stores from provider, filter by proximity to user location
    final storesState = ref.watch(storesProvider);
    var allStores = storesState.stores;
    
    print('🏪 [Nearby You] Total stores in provider: ${allStores.length}');
    
    // NOTE: We do NOT filter by selected category for "Nearby You" section
    // because it's a general recommendation section like "Popular Brands"
    // It should show nearby stores regardless of the selected category

    // Filter stores: active stores only + apply filter criteria
    final availableStores = allStores.where((s) {
      if (!s.isActive) {
        print('🏪 [Nearby You] Store ${s.name} filtered out: isActive=${s.isActive}');
        return false;
      }
      
      // Apply free delivery filter
      if (_freeDeliveryFilter && s.deliveryFee > 0) {
        return false;
      }
      
      return true;
    }).toList();

    print('🏪 [Nearby You] Available stores: ${availableStores.length}');

    // Sort based on selected sort option or default to distance
    if (_currentLatitude != null && _currentLongitude != null) {
      if (_selectedSortOption == 'rating') {
        // Sort by rating (highest first)
        availableStores.sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
        print('🏪 [Nearby You] Sorted by rating');
      } else if (_selectedSortOption == 'newest') {
        // Sort by newest (stores added recently - using merchantId as proxy)
        availableStores.sort((a, b) => b.merchantId.compareTo(a.merchantId));
        print('🏪 [Nearby You] Sorted by newest');
      } else {
        // Default: sort by distance (closest first)
        availableStores.sort((a, b) {
          final distanceA = _calculateDistance(
            _currentLatitude!,
            _currentLongitude!,
            a.latitude ?? 0,
            a.longitude ?? 0,
          );
          
          final distanceB = _calculateDistance(
            _currentLatitude!,
            _currentLongitude!,
            b.latitude ?? 0,
            b.longitude ?? 0,
          );
          
          return distanceA.compareTo(distanceB);
        });
        print('🏪 [Nearby You] Sorted by distance');
      }
    }
    
    var displayNearby = availableStores;

    // If no stores found, hide the section
    if (displayNearby.isEmpty) {
      print('🏪 [Nearby You] No stores to display, hiding section');
      return const SizedBox.shrink();
    }

    // Determine how many stores to display (with pagination)
    final storesToShow = displayNearby.take(_nearbyStoresDisplayed).toList();
    final hasMoreStores = displayNearby.length > _nearbyStoresDisplayed;

    print('🏪 [Nearby You] Showing ${storesToShow.length}/${displayNearby.length} stores');

    // Check if user is authenticated
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;
    
    // Show registration prompt after 3 pages (15 items) if not authenticated
    final REGISTRATION_THRESHOLD = STORES_PER_PAGE * 3; // 5 * 3 = 15 items
    final shouldShowRegistrationPrompt = !isAuthenticated && _nearbyStoresDisplayed > REGISTRATION_THRESHOLD;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          // Vertical list of full-width cards with infinite scroll
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: storesToShow.length + (hasMoreStores ? 1 : 0) + (shouldShowRegistrationPrompt ? 1 : 0),
            separatorBuilder: (context, index) {
              // Don't add separator after loading indicator or registration prompt
              if (hasMoreStores && index == storesToShow.length) return const SizedBox.shrink();
              if (shouldShowRegistrationPrompt && index == storesToShow.length + (hasMoreStores ? 1 : 0)) return const SizedBox.shrink();
              return const SizedBox(height: 16);
            },
            itemBuilder: (context, index) {
              // Registration prompt after loading indicator
              if (shouldShowRegistrationPrompt && index == storesToShow.length + (hasMoreStores ? 1 : 0)) {
                return _buildRegistrationPrompt();
              }

              // Last item is the loading indicator
              if (hasMoreStores && index == storesToShow.length) {
                return _buildLoadingIndicator(displayNearby);
              }

              final store = storesToShow[index];

              return GestureDetector(
                onTap: () {
                  context
                      .push('/store-details/${store.storeId}', extra: store)
                      .then((_) {
                    ref
                        .read(storesProvider.notifier)
                        .loadStores(
                          latitude: _currentLatitude,
                          longitude: _currentLongitude,
                        );
                  });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppPallete.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                            ? Image.network(
                                ImageUrlHelper.toFullUrl(store.logoUrl!) ?? store.logoUrl!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => _buildFallbackImage(),
                              )
                            : _buildFallbackImage(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: AppPallete.primaryYellow),
                                const SizedBox(width: 4),
                                Text(
                                  (store.ratingAvg)?.toStringAsFixed(1) ?? '0.0',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.schedule, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDeliveryTimeLabel(store),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppPallete.textSecondary,
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage({double height = 180}) {
    return Container(
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 52,
          color: AppPallete.primaryYellow.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  String _formatDeliveryTimeLabel(StoreEntity store) {
    final raw = store.estimatedDeliveryTime?.trim();
    if (raw != null && raw.isNotEmpty) {
      final lower = raw.toLowerCase();
      if (lower.contains('min')) return raw;
      return '$raw min';
    }
    return AppLocalizations.of(context)!.deliveryTime;
  }
  
  Widget _buildFarStoresSection() {
    // Display stores beyond 50km but within delivery range
    final storesState = ref.watch(storesProvider);
    var allStores = storesState.stores;
    
    // Apply category filter if a category is selected
    final selectedCategoryId = storesState.selectedCategory?.categoryId;
    if (selectedCategoryId != null && selectedCategoryId != 0) {
      allStores = allStores.where((store) {
        return store.categoryId == selectedCategoryId;
      }).toList();
    }

    // Filter far stores
    final farStores = allStores.where((s) {
      if (!s.isActive) return false;

      // Calculate distance
      if (_currentLatitude != null &&
          _currentLongitude != null &&
          s.latitude != null &&
          s.longitude != null) {
        final distance = _calculateDistance(
          _currentLatitude!,
          _currentLongitude!,
          s.latitude!,
          s.longitude!,
        );
        return distance > NEARBY_DISTANCE_KM &&
            distance <= MAX_DELIVERY_DISTANCE_KM;
      }
      return false;
    }).toList();

    // Sort by rating descending
    farStores.sort((a, b) => (b.ratingAvg ?? 0).compareTo(a.ratingAvg ?? 0));
    final display = farStores.take(6).toList();

    if (display.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to full stores listing
              context.push('/stores');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.stores,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textPrimary,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppPallete.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: display.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final store = display[index];
              final distance =
                  _currentLatitude != null &&
                          _currentLongitude != null &&
                          store.latitude != null &&
                          store.longitude != null
                      ? _calculateDistance(
                          _currentLatitude!,
                          _currentLongitude!,
                          store.latitude!,
                          store.longitude!,
                        )
                      : null;

              return GestureDetector(
                onTap: () {
                  context
                      .push('/store-details/${store.storeId}', extra: store)
                      .then((_) {
                        ref
                            .read(storesProvider.notifier)
                            .loadStores(
                              latitude: _currentLatitude,
                              longitude: _currentLongitude,
                            );
                      });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppPallete.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with rounded corners and centered page indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                                ? Image.network(
                                    ImageUrlHelper.toFullUrl(store.logoUrl!) ?? store.logoUrl!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      height: 160,
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: Icon(Icons.restaurant, size: 48, color: AppPallete.primaryYellow.withValues(alpha: 0.7)),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 160,
                                    color: Colors.grey[100],
                                    child: Center(
                                      child: Icon(Icons.restaurant, size: 48, color: AppPallete.primaryYellow.withValues(alpha: 0.7)),
                                    ),
                                  ),
                          ),
                          // centered dots indicator (static: number of dots equals 5 with active in middle)
                          Positioned(
                            bottom: 12,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (i) {
                                final isActive = i == 2;
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 8 : 6,
                                  height: isActive ? 8 : 6,
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white70,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),

                      // Details below image
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppPallete.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: AppPallete.primaryYellow),
                                const SizedBox(width: 6),
                                Text(
                                  (store.ratingAvg)?.toStringAsFixed(1) ?? 'N/A',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 12),
                                Image.asset('assets/images/delivery_icon.png', width: 16, height: 16, color: AppPallete.primaryTeal),
                                const SizedBox(width: 6),
                                Text(
                                  store.deliveryFee == 0 ? AppLocalizations.of(context)!.free : '${store.deliveryFee.toStringAsFixed(0)} LBP',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppPallete.primaryTeal),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "${store.estimatedDeliveryTime}m",
                                  style: TextStyle(fontSize: 12, color: AppPallete.textSecondary),
                                ),
                                const SizedBox(width: 8),
                                if (distance != null)
                                  Text(
                                    '${distance.toStringAsFixed(1)} km',
                                    style: TextStyle(fontSize: 12, color: AppPallete.textSecondary),
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
            },
          ),
        ],
      ),
    );
  }

  // Calculate distance between two coordinates using Haversine formula (in km)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371;

    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRad(double degrees) => degrees * pi / 180;



}
// Location Bottom Sheet Widget
class _LocationBottomSheet extends StatefulWidget {
  final String currentAddress;
  final double? latitude;
  final double? longitude;
  final Function(LatLng, String) onConfirm;

  const _LocationBottomSheet({
    required this.currentAddress,
    required this.onConfirm,
    this.latitude,
    this.longitude,
  });

  @override
  State<_LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<_LocationBottomSheet> {
  final Completer<GoogleMapController> _mapController = Completer();
  late LatLng _mapCenter;
  late LatLng _selectedLocation;
  String _selectedAddress = '';
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    // Use provided coordinates or default to Beirut, Lebanon
    _mapCenter = LatLng(
      widget.latitude ?? 33.8547,
      widget.longitude ?? 35.8623,
    );
    _selectedLocation = _mapCenter;
    _selectedAddress = widget.currentAddress;
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() => _isLoadingAddress = true);
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';

        setState(() {
          _selectedAddress = address;
          _selectedLocation = location;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Google Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: 14,
                  ),
                  onCameraMove: (CameraPosition position) {
                    _selectedLocation = position.target;
                  },
                  onCameraIdle: () {
                    _getAddressFromLatLng(_selectedLocation);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation,
                      infoWindow: InfoWindow(
                        title: 'Selected Location',
                        snippet: _selectedAddress,
                      ),
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  liteModeEnabled: false,
                  gestureRecognizers: {
                    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                  },
                ),
                // Center pin icon
               
              ],
            ),
          ),
          // Address display and confirm button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Address text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoadingAddress
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _selectedAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(_selectedLocation, _selectedAddress);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03833d),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirmDeliveryAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}

// Custom delegate for pinned filter chips
class _NearbyFilterChipsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _NearbyFilterChipsHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_NearbyFilterChipsHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;
}
