import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../models/models.dart' as models;

class FoodDetailScreen extends ConsumerStatefulWidget {
  final String foodNameEn;
  final String foodNameAr;
  final String restaurantName;
  final String imagePath;
  final double rating;
  final String deliveryInfo;
  final String deliveryTime;
  final double price;
  final String description;

  // Server-provided customization data
  final List<Map<String, dynamic>>? customizationGroups;

  const FoodDetailScreen({
    super.key,
    required this.foodNameEn,
    required this.foodNameAr,
    required this.restaurantName,
    required this.imagePath,
    this.rating = 4.7,
    this.deliveryInfo = 'Free',
    this.deliveryTime = '20 min',
    this.price = 32.0,
    this.description = 'A delicious dish with quality ingredients',
    this.customizationGroups,
  });

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  // Server-provided customization options
  final Map<String, dynamic> _selectedChoices = {}; // {groupId: selectedValue}
  final TextEditingController _specialRequestController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selection map from server data
    if (widget.customizationGroups != null) {
      for (var group in widget.customizationGroups!) {
        final groupId = group['id'] ?? group['title'] ?? '';
        _selectedChoices[groupId] = null;
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  double _calculateTotal() {
    double total = widget.price * _quantity;

    // Add prices from selected customizations
    if (widget.customizationGroups != null) {
      for (var group in widget.customizationGroups!) {
        final groupId = group['id'] ?? group['title'] ?? '';
        final selectedValue = _selectedChoices[groupId];

        if (selectedValue != null && group['items'] != null) {
          final items = group['items'] as List;
          final selectedItem = items.firstWhere(
            (item) =>
                item['name'] == selectedValue || item['id'] == selectedValue,
            orElse: () => null,
          );

          if (selectedItem != null && selectedItem['price'] != null) {
            total += selectedItem['price'] as double;
          }
        }
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child:
                                    widget.imagePath.startsWith('http') ||
                                        widget.imagePath.isNotEmpty
                                    ? Image.network(
                                        ImageUrlHelper.toFullUrl(
                                              widget.imagePath,
                                            ) ??
                                            widget.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.restaurant,
                                                size: 100,
                                                color: Colors.grey.shade400,
                                              );
                                            },
                                      )
                                    : Image.asset(
                                        widget.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.restaurant,
                                                size: 100,
                                                color: Colors.grey.shade400,
                                              );
                                            },
                                      ),
                              ),
                            ),
                            // Favorite button
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: _toggleFavorite,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isFavorite
                                        ? Colors.red
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Product Name and Price
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? widget.foodNameAr
                                : widget.foodNameEn,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ref
                                .read(countryCurrencyProvider.notifier)
                                .formatConvertedPriceWithSymbolFromUsd(
                                  widget.price,
                                ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Customization Section - Server-driven
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.customizationGroups != null &&
                              widget.customizationGroups!.isNotEmpty)
                            ...widget.customizationGroups!.map((group) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: _buildCustomizationGroup(group),
                              );
                            })
                          else
                            const Text(
                              'No customizations available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          // Special Request
                          _buildSpecialRequestSection(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Bottom button bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: _decrementQuantity,
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 30),
                          child: Text(
                            _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add to Cart Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          // Build a Product model from available screen data
                          final storeId =
                              ref.read(storesProvider).selectedStore?.storeId ??
                              0;
                          final product = models.Product(
                            productId: DateTime.now().millisecondsSinceEpoch
                                .remainder(1000000),
                            storeId: storeId,
                            nameAr: widget.foodNameAr,
                            nameEn: widget.foodNameEn,
                            descriptionAr: widget.description,
                            descriptionEn: widget.description,
                            price: widget.price,
                            imageUrl: widget.imagePath.startsWith('http')
                                ? widget.imagePath
                                : null,
                            category: null,
                            isAvailable: true,
                          );

                          final result = ref
                              .read(cartProvider.notifier)
                              .addItem(
                                product,
                                quantity: _quantity,
                                specialInstructions:
                                    _specialRequestController.text.isNotEmpty
                                    ? _specialRequestController.text
                                    : null,
                              );

                          if (result == AddItemResult.requiresVerification) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please verify your account before adding to cart',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (result == AddItemResult.conflict) {
                            // Ask user to confirm clearing existing cart
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.replaceCartItems,
                                ),
                                content: const Text(
                                  'Your cart contains items from another store. Clear cart and add this item?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      AppLocalizations.of(context)!.addNewItem,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final forced = ref
                                  .read(cartProvider.notifier)
                                  .addItem(
                                    product,
                                    quantity: _quantity,
                                    specialInstructions:
                                        _specialRequestController
                                            .text
                                            .isNotEmpty
                                        ? _specialRequestController.text
                                        : null,
                                    force: true,
                                  );

                              if (forced == AddItemResult.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!.addedToCart,
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                                return;
                              }
                            }

                            return;
                          }

                          // success
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.addedToCart),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add to cart',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ref
                                  .read(countryCurrencyProvider.notifier)
                                  .formatConvertedPriceWithSymbolFromUsd(
                                    _calculateTotal(),
                                  ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildCustomizationGroup(Map<String, dynamic> group) {
    final groupId = group['id'] ?? group['title'] ?? '';
    final title = group['title'] ?? 'Customization';
    final isRequired = group['isRequired'] ?? group['required'] ?? false;
    final maxSelection = group['maxSelection'] ?? group['max'] ?? 1;
    final items = group['items'] as List? ?? [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFECC4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRequired)
                const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF8C42),
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          if (maxSelection > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Up to $maxSelection',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 12),
          Column(
            children: items.map<Widget>((item) {
              final itemId = item['id'] ?? item['name'] ?? '';
              final itemName = item['name'] ?? 'Unknown';
              final itemPrice = ((item['price'] ?? 0.0) as num).toDouble();
              final isPopular = item['popular'] ?? item['isPopular'] ?? false;
              final selectedValue = _selectedChoices[groupId];
              final isSelected =
                  selectedValue == itemId || selectedValue == itemName;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (maxSelection == 1) {
                        // Single selection
                        _selectedChoices[groupId] = isSelected
                            ? null
                            : (itemId.isNotEmpty ? itemId : itemName);
                      } else {
                        // Multi-selection
                        if (_selectedChoices[groupId] == null) {
                          _selectedChoices[groupId] = [];
                        }
                        final selections = _selectedChoices[groupId] as List;
                        if (isSelected) {
                          selections.remove(
                            itemId.isNotEmpty ? itemId : itemName,
                          );
                        } else {
                          if (selections.length < maxSelection) {
                            selections.add(
                              itemId.isNotEmpty ? itemId : itemName,
                            );
                          }
                        }
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: maxSelection == 1
                                  ? BoxShape.circle
                                  : BoxShape.rectangle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                              borderRadius: maxSelection == 1
                                  ? null
                                  : BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isPopular)
                                const Text(
                                  '🔥 Popular',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF8C42),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (itemPrice > 0)
                        Text(
                          '+${ref.read(countryCurrencyProvider.notifier).formatConvertedPriceWithSymbolFromUsd(itemPrice)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequestSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFECC4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Special request',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We will notify the restaurant of your request. If it cannot be fulfilled, the order cannot be cancelled or refunded.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _specialRequestController,
            maxLines: 3,
            maxLength: 70,
            decoration: InputDecoration(
              hintText: 'Add special request...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _specialRequestController.dispose();
    super.dispose();
  }
}
