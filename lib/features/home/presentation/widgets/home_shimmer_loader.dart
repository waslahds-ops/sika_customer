import 'package:flutter/material.dart';
import 'package:sika_customer/features/home/presentation/widgets/collapsible_home_header.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/widgets/shimmer_widget.dart';

class HomeShimmerLoader extends StatefulWidget {
  const HomeShimmerLoader({super.key});

  @override
  State<HomeShimmerLoader> createState() => _HomeShimmerLoaderState();
}

class _HomeShimmerLoaderState extends State<HomeShimmerLoader> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 150,
            toolbarHeight: 0,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: CollapsibleHomeHeader(
                currentAddress: 'Current Location',
                isLoadingLocation: true,
                onLocationTap: () {},
                onSearchTap: () {},
                scrollController: _scrollController,
                showShimmer: true,
                shouldHideSearchBar: false,
                showLoginBanner: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: 5,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => _buildCategoryPlaceholder(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildRestaurantCard(),
          ),
          SliverToBoxAdapter(
            child: _buildShimmerContent(),
          ),
        ],
      ),
    );
  }



  Widget _buildRestaurantCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: ShimmerWidget(
        width: double.infinity,
        height: 120,
        borderRadius: BorderRadius.circular(20),
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
      ),
    );
  }

  Widget _buildShimmerContent() {
    final width = MediaQuery.of(context).size.width - 32;
    return IgnorePointer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(3, (_) => _buildListItemPlaceholder(width)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPlaceholder() {
    return ShimmerWidget(
      width: 60,
      height: 60,
      borderRadius: BorderRadius.circular(16),
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
    );
  }

  Widget _buildListItemPlaceholder(double width) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            width: double.infinity,
            height: 150,
            borderRadius: BorderRadius.zero,
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(
                  width: width * 0.4,
                  height: 18,
                  borderRadius: BorderRadius.circular(8),
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade100,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerWidget(
                      width: 80,
                      height: 14,
                      borderRadius: BorderRadius.circular(6),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade100,
                    ),
                    const SizedBox(width: 12),
                    ShimmerWidget(
                      width: 60,
                      height: 14,
                      borderRadius: BorderRadius.circular(6),
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade100,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
