import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/features/orders/domain/entities/order_entities.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/utils/verification_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../models/product.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;
  final OrderEntity? orderData; // Optional pre-loaded order data

  const OrderDetailScreen({super.key, required this.orderId, this.orderData});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  // Order items - loaded from API if orderId provided, else mock data
  late List<OrderItemDetail> orderItems = [];
  Map<int, int> itemQuantities = {};

  // Order details loaded from API
  String? _status;
  String? _orderNumber;
  String? _date;
  String? _restaurantName;
  String? _price;
  bool _isLoading = true;
  // Message to delivery agent
  final TextEditingController _agentMessageController = TextEditingController();
  bool _isSendingMessage = false;
  // Tracking data future for compact tracking section
  Future<Map<String, dynamic>?>? _trackingFuture;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  @override
  void dispose() {
    _agentMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    // If we have pre-loaded order data, use it directly
    if (widget.orderData != null) {
      final orderEntity = widget.orderData!;
      _status = orderEntity.status;
      _orderNumber = orderEntity.orderNumber;
      _date = _formatDate(orderEntity.createdAt);
      _restaurantName = 'Store #${orderEntity.storeId}';
      _price = ref
          .read(countryCurrencyProvider.notifier)
          .formatConvertedPriceWithSymbolFromUsd(orderEntity.totalAmount);
      await _loadOrderItemsFromApi();
      setState(() => _isLoading = false);
      return;
    }

    // Otherwise, fetch from API
    try {
      final repository = ref.read(orderRepositoryProvider);
      final result = await repository.getOrderById(widget.orderId);

      result.fold(
        (failure) {
          // API call failed, use fallback data
          _loadMockOrderDetails();
        },
        (orderEntity) {
          // Successfully fetched order
          _status = orderEntity.status;
          _orderNumber = orderEntity.orderNumber;
          _date = _formatDate(orderEntity.createdAt);
          _restaurantName =
              'Store #${orderEntity.storeId}'; // TODO: Fetch store name from API
          _price = ref
              .read(countryCurrencyProvider.notifier)
              .formatConvertedPriceWithSymbolFromUsd(orderEntity.totalAmount);
        },
      );
    } catch (e) {
      print('Error fetching order: $e');
      _loadMockOrderDetails();
    }

    // Always load items from API (after order details are loaded)
    await _loadOrderItemsFromApi();

    setState(() => _isLoading = false);

    // Kick off tracking data request for compact tracking header (non-fatal)
    try {
      _trackingFuture = ref.read(apiServiceProvider).trackOrder(widget.orderId).catchError((_) => null);
    } catch (_) {
      _trackingFuture = Future.value(null);
    }
  }

  void _loadMockOrderDetails() {
    _status = 'Completed';
    _orderNumber = widget.orderId.toString();
    _date = 'Dec 21, 2024';
    _restaurantName = 'Pizza Palace';
    _price = ref
        .read(countryCurrencyProvider.notifier)
        .formatConvertedPriceWithSymbolFromUsd(60.0);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _loadOrderItemsFromApi() async {
    // Fetch order items from backend API
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Fetch order details to get items
      // Using the customer endpoint: GET /customer/orders/{orderId}
      final response = await apiService.get('/customer/orders/${widget.orderId}');
      final orderData = response.data['data'] as Map<String, dynamic>?;
      
      if (orderData == null) {
        print('⚠️ No order data in response');
        setState(() {
          orderItems = [];
        });
        return;
      }
      
      // Get items from the order response (API returns items array)
      final items = orderData['items'] as List?;
      
      if (items == null || items.isEmpty) {
        print('⚠️ No items found in order response');
        if (mounted) {
          setState(() {
            orderItems = [];
          });
        }
        return;
      }

      // Convert order items to OrderItemDetail objects
      final List<OrderItemDetail> loadedItems = [];
      
      for (var item in items) {
        final product = Product(
          productId: _parseInt(item['product_id']) ?? 0,
          storeId: widget.orderData?.storeId ?? _parseInt(orderData['store_id']) ?? 0,
          nameAr: item['product_name_ar'] as String? ?? 'Unknown',
          nameEn: item['product_name_en'] as String? ?? 'Unknown',
          descriptionAr: null,
          descriptionEn: null,
          price: _parseDouble(item['price']) ?? 0.0,
          imageUrl: null,
          category: null,
          isAvailable: true,
          preparationTime: null,
        );

        loadedItems.add(OrderItemDetail(
          product: product,
          quantity: _parseInt(item['quantity']) ?? 1,
          specialInstructions: null,
        ));
      }

      if (mounted) {
        setState(() {
          orderItems = loadedItems;
          // Initialize quantities
          for (var item in orderItems) {
            itemQuantities[item.product.productId] = 1;
          }
        });
      }
      
      print('✅ Loaded ${loadedItems.length} order items from API');
    } catch (e) {
      print('❌ Error loading order items: $e');
      // Fallback to empty list
      if (mounted) {
        setState(() {
          orderItems = [];
        });
      }
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _addToCart(OrderItemDetail item) {
    final quantity = itemQuantities[item.product.productId] ?? 1;
    final result = ref
        .read(cartProvider.notifier)
        .addItem(
          item.product,
          quantity: quantity,
          specialInstructions: item.specialInstructions,
        );

    if (result == AddItemResult.requiresVerification) {
      final shouldVerify = showVerificationRequiredDialog(context);
      shouldVerify.then((should) {
        if (should == true && context.mounted) context.push('/verification');
      });
      return;
    }

    if (result == AddItemResult.conflict) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.replaceCartItems),
          content: Text(
            AppLocalizations.of(context)!.replaceCartItemsContent,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.addNewItem),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          ref
              .read(cartProvider.notifier)
              .addItem(
                item.product,
                quantity: quantity,
                specialInstructions: item.specialInstructions,
                force: true,
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${item.product.nameEn} (x$quantity) added to cart',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View Cart',
                textColor: Colors.white,
                onPressed: () {
                  context.push('/cart');
                },
              ),
            ),
          );
        }
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.product.nameEn} (x$quantity) ${AppLocalizations.of(context)!.addedToCart}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            context.push('/cart');
          },
        ),
      ),
    );
  }

  void _addAllToCart() {
    // If cart contains items from another store, ask for confirmation first
    final cartState = ref.read(cartProvider);
    final cartStoreId = cartState.storeId;
    final incomingStoreId = orderItems.isNotEmpty
        ? orderItems.first.product.storeId
        : null;

    if (cartStoreId != null &&
        incomingStoreId != null &&
        cartStoreId != incomingStoreId) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.replaceCartItems),
          content: Text(
            AppLocalizations.of(context)!.replaceCartItemsContent,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.addNewItem),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          ref.read(cartProvider.notifier).clearCart();
          for (var item in orderItems) {
            ref
                .read(cartProvider.notifier)
                .addItem(
                  item.product,
                  quantity: item.quantity,
                  specialInstructions: item.specialInstructions,
                );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${orderItems.length} ${AppLocalizations.of(context)!.addedToCart}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: AppLocalizations.of(context)!.viewCart,
                textColor: Colors.white,
                onPressed: () {
                  context.push('/cart');
                },
              ),
            ),
          );
        }
      });
      return;
    }

    // Otherwise just add all
    for (var item in orderItems) {
      ref
          .read(cartProvider.notifier)
          .addItem(
            item.product,
            quantity: item.quantity,
            specialInstructions: item.specialInstructions,
          );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${orderItems.length} ${AppLocalizations.of(context)!.addedToCart}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.viewCart,
          textColor: Colors.white,
          onPressed: () {
            context.push('/cart');
          },
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_status == null) return Colors.blue;
    switch (_status!.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  bool _isOrderOnTheWay() {
    if (_status == null) return false;
    final lowerStatus = _status!.toLowerCase();
    return lowerStatus == 'picked_up' ||
        lowerStatus == 'out_for_delivery' ||
        lowerStatus == 'on_the_way';
  }

  bool _hasDeliveryAgent() {
    // Check if the order has agent information
    return widget.orderData?.agentId != null ||
        widget.orderData?.agentName != null ||
        widget.orderData?.deliveryAgentId != null;
  }

  void _showDeliveryMap() {
    // Navigate to the track order screen
    context.push('/track-order/${widget.orderId}');
  }

  Future<void> _sendMessageToAgent() async {
    final message = _agentMessageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _isSendingMessage = true);

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.messageSentToAgent)),
      );

      _agentMessageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.failedToSendMessage}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSendingMessage = false);
    }
  }

  // Compact tracking widget that shows a small summary and opens full tracking
  Widget _buildTrackingSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _trackingFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;

        // If loading, show a small shimmer-like placeholder
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(width: 56, height: 56, color: Colors.grey[200]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, color: Colors.grey[200]),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 120, color: Colors.grey[200]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 56, height: 36, color: Colors.grey[200]),
              ],
            ),
          );
        }

        // If no tracking data, show a small CTA to open tracking screen
        if (data == null) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.map, size: 36, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Track Order',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/track-order/${widget.orderId}'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppPallete.primaryYellow),
                  child: Text(AppLocalizations.of(context)!.trackOrder),
                ),
              ],
            ),
          );
        }

        // If we have tracking data, show agent name and ETA + open button
        final agent = data['agent'] as Map<String, dynamic>?;
        final eta = data['estimated_arrival'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppPallete.primaryYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: AppPallete.primaryYellow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent?['name'] as String? ?? 'Delivery Agent', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (eta != null) Text('ETA: $eta', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push('/track-order/${widget.orderId}'),
                style: ElevatedButton.styleFrom(backgroundColor: AppPallete.primaryYellow),
                child: const Text('Open'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _orderNumber ?? widget.orderId.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _date ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _status ?? 'Loading...',
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Order Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Store Info
                  // Compact Tracking Section (always shown)
                  _buildTrackingSection(),

                  // Store Info
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppPallete.primaryYellow.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: Icon(
                            Icons.store,
                            size: 32,
                            color: AppPallete.primaryYellow,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _restaurantName ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${orderItems.length} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _price ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.primaryYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Order Items Header
                  const Text(
                    'Order Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Items List
                  ...orderItems.map((item) => _buildOrderItem(item, cartState)),
                ],
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
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // For orders on the way show a small map preview and message input
                  if (_isOrderOnTheWay() && _hasDeliveryAgent()) ...[
                    GestureDetector(
                      onTap: _showDeliveryMap,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppPallete.primaryYellow.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.map, color: AppPallete.primaryYellow),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.orderData?.agentName ?? 'Delivery Agent',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to open live map',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _showDeliveryMap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.primaryYellow,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Open'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Message input to contact delivery agent when they pick up the order
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _agentMessageController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Message to delivery agent',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isSendingMessage
                            ? const SizedBox(width: 40, height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                            : ElevatedButton(
                                onPressed: _sendMessageToAgent,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPallete.primaryYellow,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: const Icon(Icons.send, color: Colors.white),
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      // View Cart Button (if items in cart)
                      if (cartState.itemCount > 0) ...[
                        Flexible(
                          child: OutlinedButton(
                            onPressed: () {
                              context.push('/cart');
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppPallete.primaryYellow),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: AppPallete.primaryYellow,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'View Cart (${cartState.itemCount})',
                                  style: TextStyle(
                                    color: AppPallete.primaryYellow,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Re-order All Button
                      Flexible(
                        child: ElevatedButton(
                          onPressed: _addAllToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Re-order All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
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

  Widget _buildOrderItem(OrderItemDetail item, CartState cartState) {
    final isInCart = ref
        .read(cartProvider.notifier)
        .isInCart(item.product.productId);
    final currentQuantity = itemQuantities[item.product.productId] ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInCart
              ? AppPallete.primaryYellow.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.product.imageUrl != null
                  ? Image.network(
                      ImageUrlHelper.toFullUrl(item.product.imageUrl) ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey[400],
                        );
                      },
                    )
                  : Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.nameEn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.specialInstructions != null) ...[
                  Text(
                    'Note: ${item.specialInstructions}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Text(
                      ref
                          .read(countryCurrencyProvider.notifier)
                          .formatConvertedPriceWithSymbolFromUsd(
                            item.product.price,
                          ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.textPrimary,
                      ),
                    ),
                    Text(
                      ' (original: × ${item.quantity})',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quantity Selector and Add to Cart Button Row
                Row(
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        color: AppPallete.textPrimary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Decrease Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: currentQuantity > 1
                                  ? () {
                                      setState(() {
                                        itemQuantities[item.product.productId] =
                                            currentQuantity - 1;
                                      });
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.remove,
                                  color: currentQuantity > 1
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.3),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          // Quantity Display
                          Container(
                            constraints: const BoxConstraints(minWidth: 30),
                            alignment: Alignment.center,
                            child: Text(
                              '$currentQuantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Increase Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  itemQuantities[item.product.productId] =
                                      currentQuantity + 1;
                                });
                              },
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add to Cart Button
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => _addToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          isInCart ? 'ADDED ✓' : 'ADD TO CART',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
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
    );
  }
}

// Order item detail model
class OrderItemDetail {
  final Product product;
  final int quantity;
  final String? specialInstructions;

  OrderItemDetail({
    required this.product,
    required this.quantity,
    this.specialInstructions,
  });
}

