import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/error/failures.dart';
import '../../../../injection_container.dart';
import '../../../stores/domain/entities/store_entities.dart';
import 'package:dartz/dartz.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.4;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: Image.asset(
                        widget.product.imageUrl ?? 'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: MediaQuery.of(context).padding.top + 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        widget.product.nameEn,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.product.preparationTime ?? '500g',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? (widget.product.descriptionAr ?? '')
                              : (widget.product.descriptionEn ?? ''),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LBP ${widget.product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${(widget.product.price / 90000).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionTile(),
                        const SizedBox(height: 42),
                        _buildQuantityRow(),
                        const SizedBox(height: 16),
                        _buildActionRow(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile() {
    return ExpansionTile(
      title: Text(
        AppLocalizations.of(context)!.anyInstructions,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
      children: [
        TextField(
          controller: _instructionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.instructionsHint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onTap: () => _onQuantityChanged(-1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            '$_quantity',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          backgroundColor: AppPallete.primaryYellow,
          onTap: () => _onQuantityChanged(1),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    final price = widget.product.price;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  '\$${(price * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: backgroundColor,
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onTap,
      ),
    );
  }
}

class ProductDetailsLoader extends ConsumerStatefulWidget {
  final int productId;
  final ProductEntity? initialProduct;

  const ProductDetailsLoader({
    super.key,
    this.initialProduct,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsLoader> createState() =>
      _ProductDetailsLoaderState();
}

class _ProductDetailsLoaderState
    extends ConsumerState<ProductDetailsLoader> {
  late final Future<Either<Failure, ProductEntity>> _productFuture;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _productFuture = Future.value(right(widget.initialProduct!));
    } else {
      _productFuture =
          ref.read(getProductByIdUseCaseProvider)(widget.productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<Either<Failure, ProductEntity>>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context)!.productNotFound),
            ),
          );
        }

        return snapshot.data!.fold(
          (failure) => Scaffold(
            body: Center(
              child: Text(
                failure.message.isNotEmpty
                    ? failure.message
                    : l10n.unknownError,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          (product) => ProductDetailsScreen(product: product),
        );
      },
    );
  }
}
