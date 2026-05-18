import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sika_customer/core/constants/app_pallete.dart';
import 'package:sika_customer/core/widgets/shimmer_widget.dart';

class CollapsibleHomeHeader extends ConsumerStatefulWidget {
  final String currentAddress;
  final bool isLoadingLocation;
  final VoidCallback onLocationTap;
  final VoidCallback onSearchTap;
  final String searchHint;
  final ScrollController scrollController;
  final bool showLoginBanner;
  final VoidCallback? onLoginTap;
  final bool shouldHideSearchBar;
  final bool showShimmer;

  const CollapsibleHomeHeader({
    super.key,
    required this.currentAddress,
    required this.isLoadingLocation,
    required this.onLocationTap,
    required this.onSearchTap,
    required this.scrollController,
    this.showLoginBanner = false,
    this.onLoginTap,
    this.searchHint = "McDonald's",
    this.shouldHideSearchBar = false,
    this.showShimmer = false,
  });

  @override
  ConsumerState<CollapsibleHomeHeader> createState() =>
      _CollapsibleHomeHeaderState();
}

class _CollapsibleHomeHeaderState extends ConsumerState<CollapsibleHomeHeader> {
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final baseMaxHeaderHeight = (isTablet ? 320.0 : 200.0) + statusBarHeight;
    final baseMinHeaderHeight = (isTablet ? 120.0 : 60.0) + statusBarHeight;
    final heightScale = widget.showShimmer ? 0.65 : 1.0;
    final maxHeaderHeight = baseMaxHeaderHeight * heightScale;
    final minHeaderHeight = baseMinHeaderHeight * heightScale;

    // Calculate how much the header has collapsed
    final collapsedPercentage =
        (_scrollOffset / (maxHeaderHeight - minHeaderHeight)).clamp(0.0, 1.0);

    final searchBarStartTop = statusBarHeight + 80;
    final searchBarEndTop = statusBarHeight + 12;
    final searchTop = lerpDouble(searchBarStartTop, searchBarEndTop, collapsedPercentage)!;
    final searchBarShadowColor = Colors.black.withOpacity(
      (0.3 + collapsedPercentage * 0.2).clamp(0.3, 0.5),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;
       return SizedBox(
      
        height: maxHeaderHeight -
            (_scrollOffset.clamp(0.0, maxHeaderHeight - minHeaderHeight)),
        child: Stack(
          children: [
            _buildBackground(maxHeaderHeight),
            if (widget.showShimmer)
              Positioned(
                top: statusBarHeight + 20,
                left:  16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/sika Logo.png',
                      height: isTablet ? 70 : 36,
                      width:  isTablet ? 180 : 90,
                      fit: BoxFit.contain,
                    ),
                    GestureDetector(
                      onTap: widget.onLocationTap,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            widget.currentAddress,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Positioned(
                top: statusBarHeight + 20,
                left: 8,
                child: Opacity(
                  opacity: 1.0 - collapsedPercentage,
                  child: Image.asset(
                    'assets/images/sika Logo.png',
                      height: isTablet ? 70 : 36,
                      width:  isTablet ? 180 : 90,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: isTablet ? 70 : 36,
                        width: isTablet ? 180 : 90,
                        color:  AppPallete.transparent,
                        child: const Center(
                          child: Text(
                            'Sika',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: statusBarHeight + 30,
                child: Opacity(
                  opacity: 1.0 - collapsedPercentage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onLocationTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.asset(
                                "assets/icons/marker_icon.png",
                                width: 18,
                                height: 18,
                              ),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 140),
                              child: Text(
                                widget.currentAddress,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Search bar - moves to top as you scroll (hidden when app bar search bar shows)
            if (!widget.shouldHideSearchBar)
              Positioned(
                left: 9,
                right: 9,
                top: searchTop,
                child: Transform.translate(
                  offset: Offset(0, collapsedPercentage * -6),
                  child: GestureDetector(
                    onTap: widget.onSearchTap,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: searchBarShadowColor,
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/icons/search.svg"),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              
                              widget.searchHint,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (!widget.showShimmer)
            Positioned(
              left: -2,
              right: -2,
              top:
                  statusBarHeight + 130 - (_scrollOffset * 0.5).clamp(0.0, 100.0),
              child: Opacity(
                opacity: (1.0 - collapsedPercentage * 0.5).clamp(0.0, 1.0),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF094d26), Color(0xFF004b2e)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enjoy Your Vouchers! Order Now!',
                                    style: TextStyle(
                                      color: Color(0xFFFBEF53),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SAVE UP TO',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '500,000',
                                          style: TextStyle(
                                            color: Color(0xFFFBEF53),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\nLBP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Gift visuals on the right - use provided asset 'gifts.png'
                            SizedBox(
                              width: 140,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    right: -20,
                                    top: -60,
                                    child: Transform.scale(
                                    scale: 1.25,
                                    alignment: Alignment.topRight,
                                    child: Image.asset(
                                      'assets/images/gifts.png',
                                      width: 150,
                                      height: 120,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, st) => SizedBox.shrink(),
                                    ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),                     
                      ],
                    ),
                  ),
                ),
              ),
            ),          
            if(!widget.showShimmer)
      Positioned(
                left: 0,
                right: 0,
                top:
                    statusBarHeight + 248 - (_scrollOffset * 0.5).clamp(0.0, 100.0),
                child: Transform.translate(
                  offset: const Offset(0, -6), // slightly lifted to sit on top
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                        gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.95), Color(0xFF005225).withOpacity(0.95)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.6, 1.0],
                        ),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/delivery_icon.png"),
                        SizedBox(width: 8),
                        Image(image: AssetImage("assets/images/header_title.png"),),
                      ],
                    ),
                  ),
                ),
              ),
      
          ],
        ),
      );
      }
    );
  }

  Widget _buildBackground(double height) {

    if(widget.showShimmer) {
      return SizedBox(
        height: height,
        width: double.infinity,

      );
    }
    return 
    SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        'assets/images/Header.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildShimmerContent(double statusBarHeight) {
    final width = MediaQuery.of(context).size.width - 32;
    return IgnorePointer(
      child: Column(
        children: [
          SizedBox(height: statusBarHeight + 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLogoPlaceholder(),
                    const Spacer(),
                    _buildLocationPlaceholder(),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _shimmerCircle(size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerLine(width: width * 0.65, height: 16),
                          const SizedBox(height: 6),
                          _shimmerLine(width: width * 0.45, height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _shimmerCircle(size: 20),
                  ],
                ),
                const SizedBox(height: 22),
                ShimmerWidget(
                  width: double.infinity,
                  height: 48,
                  borderRadius: BorderRadius.circular(24),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                  highlightWidth: 0.25,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (_) => _buildCategoryPlaceholder()),
                ),
                const SizedBox(height: 24),
                Column(
                  children: List.generate(3, (_) => _buildListItemPlaceholder(width)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPlaceholder() {
    return Column(
      children: [
        ShimmerWidget(
          width: 56,
          height: 56,
          borderRadius: BorderRadius.circular(16),
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
        ),
        const SizedBox(height: 8),
        ShimmerLine(
          width: 40,
          height: 10,
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
        ),
      ],
    );
  }

  Widget _buildListItemPlaceholder(double width) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ShimmerWidget(
            width: 100,
            height: 90,
            borderRadius: BorderRadius.circular(16),
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(width: width * 0.55, height: 16),
                const SizedBox(height: 10),
                _shimmerLine(width: width * 0.4, height: 12),
                const SizedBox(height: 10),
                _shimmerLine(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLogoPlaceholder() {
    return ShimmerWidget(
      width: 110,
      height: 32,
      borderRadius: BorderRadius.circular(12),
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
    );
  }

  Widget _buildLocationPlaceholder() {
    return Row(
      children: [
        _shimmerCircle(size: 12),
        const SizedBox(width: 6),
        _shimmerLine(width: 90, height: 12),
      ],
    );
  }

  Widget _shimmerLine({double width = 100, double height = 14}) {
    return ShimmerLine(
      width: width,
      height: height,
      baseColor: Colors.grey.shade300,
    );
  }

  Widget _shimmerCircle({double size = 40}) {
    return ShimmerCircle(
      size: size,
      baseColor: Colors.grey.shade300,
    );
  }
}
