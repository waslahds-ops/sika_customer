import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../models/product.dart';
import '../../../models/keeta_features.dart';

class ProductCustomizationModal extends ConsumerStatefulWidget {
  final Product product;
  final Function(Product, ProductSize?, List<ProductAddon>, String?)
  onAddToCart;

  const ProductCustomizationModal({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  ConsumerState<ProductCustomizationModal> createState() =>
      _ProductCustomizationModalState();
}

class _ProductCustomizationModalState
    extends ConsumerState<ProductCustomizationModal> {
  ProductSize? _selectedSize;
  final Set<ProductAddon> _selectedAddons = {};
  final TextEditingController _specialRequestController =
      TextEditingController();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Auto-select first size if available
    if (widget.product.availableSizes?.isNotEmpty ?? false) {
      _selectedSize = widget.product.availableSizes!.first;
    }
  }

  @override
  void dispose() {
    _specialRequestController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double price = widget.product.price;

    // Add size price modifier
    if (_selectedSize != null) {
      price += _selectedSize!.priceModifier;
    }

    // Add selected addons
    for (var addon in _selectedAddons) {
      price += addon.price;
    }

    return price * _quantity;
  }

  bool get _canAddToCart {
    // Check if required addons are selected
    if (widget.product.availableAddons != null) {
      for (var addon in widget.product.availableAddons!) {
        if (addon.isRequired && !_selectedAddons.contains(addon)) {
          return false;
        }
      }
    }

    // Check if size is required
    if (widget.product.availableSizes != null &&
        widget.product.availableSizes!.isNotEmpty &&
        _selectedSize == null) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Product Image & Header
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.nameEn,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.product.descriptionEn != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.product.descriptionEn!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ref
                            .read(countryCurrencyProvider.notifier)
                            .formatConvertedPriceWithSymbolFromUsd(
                              widget.product.price,
                            ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  // Sizes Selection
                  if (widget.product.availableSizes != null &&
                      widget.product.availableSizes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.availableSizes!.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppPallete.primaryTeal
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? AppPallete.primaryTeal
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  size.nameEn,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (size.priceModifier > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '+${ref.read(countryCurrencyProvider.notifier).formatConvertedPriceWithSymbolFromUsd(size.priceModifier)}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  // Add-ons Selection
                  if (widget.product.availableAddons != null &&
                      widget.product.availableAddons!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Add-ons',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.product.availableAddons!.map((addon) {
                      final isSelected = _selectedAddons.contains(addon);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? AppPallete.primaryTeal
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? AppPallete.primaryTeal.withValues(alpha: 0.05)
                              : Colors.white,
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedAddons.add(addon);
                              } else {
                                if (!addon.isRequired) {
                                  _selectedAddons.remove(addon);
                                }
                              }
                            });
                          },
                          title: Row(
                            children: [
                              Text(
                                addon.nameEn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (addon.isRequired) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Required',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: addon.descriptionEn != null
                              ? Text(
                                  addon.descriptionEn!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                )
                              : null,
                          secondary: Text(
                            '+${ref.read(countryCurrencyProvider.notifier).formatConvertedPriceWithSymbolFromUsd(addon.price)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppPallete.primaryTeal,
                            ),
                          ),
                          activeColor: AppPallete.primaryTeal,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }),
                  ],
                  // Special Instructions
                  const SizedBox(height: 24),
                  const Text(
                    'Special Instructions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _specialRequestController,
                    textDirection: TextDirection.ltr,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Any special requests? (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 80), // Space for bottom bar
                ],
              ),
            ),
          ),
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
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
                  const SizedBox(width: 16),
                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canAddToCart
                          ? () {
                              widget.onAddToCart(
                                widget.product,
                                _selectedSize,
                                _selectedAddons.toList(),
                                _specialRequestController.text.isNotEmpty
                                    ? _specialRequestController.text
                                    : null,
                              );
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ref
                                .read(countryCurrencyProvider.notifier)
                                .formatConvertedPriceWithSymbolFromUsd(
                                  _totalPrice,
                                ),
                            style: const TextStyle(
                              fontSize: 16,
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
            ),
          ),
        ],
      ),
    );
  }
}
