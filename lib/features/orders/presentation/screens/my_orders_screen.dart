import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  // Cache for store names to avoid repeated API calls
  final Map<int, String?> _storeNameCache = {};

  @override
  void initState() {
    super.initState();
    // Load both lists so completed orders are always available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadInProgressOrders();
      ref.read(ordersProvider.notifier).loadCompletedOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  l10n.myOrders,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Unified Orders Page: show active order first (if any), then completed orders
            Expanded(
              child: _buildUnifiedOrdersView(),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildUnifiedOrdersView() {
    final ordersState = ref.watch(ordersProvider);
    final inProgress = ordersState.inProgressOrders;
    final completed = ordersState.completedOrders;

    // If loading and no data yet
    if (ordersState.isLoading && inProgress.isEmpty && completed.isEmpty) {
      return const Center(child: AppLoader());
    }

    if (ordersState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              ordersState.errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // reload both lists
                ref.read(ordersProvider.notifier).loadInProgressOrders();
                ref.read(ordersProvider.notifier).loadCompletedOrders();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.gold,
              ),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    // Build a combined, scrollable list where the first item is the most relevant
    final hasActive = inProgress.isNotEmpty;
    final totalItems = (hasActive ? 1 : 0) + completed.length;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(ordersProvider.notifier).loadInProgressOrders();
        ref.read(ordersProvider.notifier).loadCompletedOrders();
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: totalItems == 0 ? 1 : totalItems,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (totalItems == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noInProgressOrders,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          // If there's an active order, show it first
          if (hasActive && index == 0) {
            final order = inProgress.first;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prominent active order header (Toters-like)
                  Text(
                    'Current order',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildActiveOrderHighlight(order, context),
                ],
              ),
            );
          }

          // Otherwise calculate index into completed list
          final completedIndex = hasActive ? index - 1 : index;
          // Before first completed item, show a header
          if ((hasActive && index == 1) || (!hasActive && index == 0)) {
            // if there are no completed orders this branch won't render list items
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Completed orders',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOrderCardFromEntity(completed[completedIndex], context),
                ),
              ],
            );
          }

          final order = completed[completedIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCardFromEntity(order, context),
          );
        },
      ),
    );
  }

  Widget _buildActiveOrderHighlight(dynamic order, BuildContext context) {
    final status = order.status;
    final progress = _progressFromStatus(status);

    return GestureDetector(
      onTap: () => context.push('/order-detail/${order.orderId}', extra: order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: _getStoreName(order.storeId),
                        builder: (context, snapshot) {
                          final storeName = snapshot.data ?? order.storeName ?? 'Store #${order.storeId}';
                          return Text(
                            storeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _capitalizeStatus(status),
                        style: TextStyle(color: _getStatusColor(status)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ref
                          .read(countryCurrencyProvider.notifier)
                          .formatConvertedPriceWithSymbolFromUsd(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('#${order.orderNumber}', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: _getStatusColor(status),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/order-detail/${order.orderId}', extra: order);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryYellow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(AppLocalizations.of(context)!.orderDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _progressFromStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('picked_up') || s.contains('out_for_delivery') || s.contains('on_the_way')) return 0.9;
    if (s == 'ready') return 0.7;
    if (s == 'preparing') return 0.4;
    if (s == 'confirmed') return 0.2;
    return 0.1;
  }

  Widget _buildOrderCardFromEntity(dynamic order, BuildContext context) {
    final status = order.status;
    final statusColor = _getStatusColor(status);
    final isOnTheWay =
        status.toLowerCase() == 'picked_up' ||
        status.toLowerCase() == 'out_for_delivery' ||
        status.toLowerCase() == 'on_the_way';

    return GestureDetector(
      onTap: () {
        context.push('/order-detail/${order.orderId}', extra: order);
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: statusColor),
                const SizedBox(width: 16),
                Text(
                  _capitalizeStatus(status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Store name - prominent (fetched on-demand with caching)
            FutureBuilder<String>(
              future: _getStoreName(order.storeId),
              builder: (context, snapshot) {
                final storeName = snapshot.data ?? order.storeName ?? 'Store #${order.storeId}';
                return Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Order items preview
            FutureBuilder<List<String>>(
              future: _getOrderItemsPreview(order.orderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 30,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final items = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Text(
                          item,
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      );
                    }).toList(),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 12),
            
            // Total amount - bold and prominent
            Text(
              'Total: ${ref.read(countryCurrencyProvider.notifier).formatConvertedPriceWithSymbolFromUsd(order.totalAmount)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            // Map view for "On the way" orders
            if (isOnTheWay && _hasDeliveryAgent(order)) ...[
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Placeholder map background
                      Container(
                        color: Colors.blue[50],
                        child: Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: Colors.blue[300],
                          ),
                        ),
                      ),
                      // Delivery agent marker
                      Positioned(
                        top: 40,
                        left: 60,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.delivery_dining,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                        ),
                      ),
                      // Customer location marker
                      Positioned(
                        bottom: 40,
                        right: 60,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red[600],
                            size: 20,
                          ),
                        ),
                      ),
                      // Track button overlay
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/track-order/${order.orderId}');
                          },
                          icon: const Icon(Icons.location_on, size: 16),
                          label: const Text(
                            'Track Delivery',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            // Delivery Agent Info (if order is picked up or in delivery)
            if (order.agentId != null &&
                (status.toLowerCase() == 'picked_up' ||
                    status.toLowerCase() == 'confirmed' ||
                    status.toLowerCase() == 'preparing' ||
                    status.toLowerCase() == 'ready')) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[100],
                      ),
                      child: Icon(
                        Icons.person_outlined,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Agent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (order.agentName != null &&
                              order.agentName!.isNotEmpty)
                            Text(
                              order.agentName ?? 'Assigned',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (order.agentVehiclePlate != null)
                            Text(
                              '${order.agentVehicleType ?? 'Vehicle'} • ${order.agentVehiclePlate}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                // Rate button for delivered orders
                if (status.toLowerCase() == 'delivered') ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // _showReviewDialog(context, order);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppPallete.primaryYellow),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Rate & Review',
                        style: TextStyle(
                          color: AppPallete.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // QR Code button
                if (isOnTheWay && order.hasQrCode) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showQrCodeDialog(context, order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: const Text(
                        'Show QR Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                // For "On the way" orders, show View Details button (map already has track button)
                if (isOnTheWay) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/order-detail/${order.orderId}',
                          extra: order,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ]
                // Track Driver button for other trackable orders
                else if (order.canTrack && _hasDeliveryAgent(order)) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/track-order/${order.orderId}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.location_on, size: 18),
                      label: const Text(
                        'Track Driver',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/order-detail/${order.orderId}',
                          extra: order,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        status.toLowerCase() == 'delivered'
                            ? 'Re-Order'
                            : 'View Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return status;
    return status
        .split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    switch (lowerStatus) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.indigo;
      case 'picked_up':
      case 'out_for_delivery':
      case 'on_the_way':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'cancelled_by_customer':
      case 'cancelled_by_restaurant':
        return Colors.red;
      case 'failed':
        return Colors.red[800]!;
      default:
        return AppPallete.primaryYellow;
    }
  }

  bool _hasDeliveryAgent(dynamic order) {
    // Check if the order has agent information
    return order.agentId != null ||
        order.agentName != null ||
        order.deliveryAgentId != null;
  }

  void _showQrCodeDialog(BuildContext context, dynamic order) {
    print('📱 QR Code URL: ${order.qrCodeUrl}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Show this QR code to your delivery agent'),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: order.qrCodeUrl != null
                    ? Image.network(
                        ImageUrlHelper.toFullUrl(order.qrCodeUrl) ??
                            order.qrCodeUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ QR Code image load error: $error');
                          return const Icon(
                            Icons.qr_code,
                            size: 100,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(Icons.qr_code, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Valid until scanned by delivery agent',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Fetch store name with caching to avoid rate limiting
  /// Returns cached value if available, otherwise fetches from API
  Future<String> _getStoreName(int storeId) async {
    // Return cached value if available
    if (_storeNameCache.containsKey(storeId)) {
      final cached = _storeNameCache[storeId];
      return cached ?? 'Store #$storeId';
    }

    try {
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.get('/public/stores/$storeId');
      
      final name = response.data['data']?['name'] ?? 
                   response.data['name'] ?? 
                   'Store #$storeId';
      
      // Cache the result
      _storeNameCache[storeId] = name;
      return name;
    } catch (e) {
      print('⚠️ Error fetching store name for $storeId: $e');
      // Cache the failure to avoid repeated requests
      _storeNameCache[storeId] = null;
      return 'Store #$storeId';
    }
  }

  Future<List<String>> _getOrderItemsPreview(int orderId) async {
    try {
      // Use the DioClient directly to fetch order items
      final dioClient = ref.read(dioClientProvider);
      final response = await dioClient.get('/customer/orders/$orderId');
      
      final orderData = response.data['data'] ?? response.data;
      final items = orderData['items'] as List?;
      
      if (items == null || items.isEmpty) {
        return [];
      }
      
      // Return first few items as preview
      return items
          .cast<Map<String, dynamic>>()
          .take(3)
          .map((item) {
            final quantity = item['quantity'] ?? 1;
            final name = item['product_name_en'] ?? item['product_name'] ?? 'Item';
            return '$quantity $name';
          })
          .toList();
    } catch (e) {
      print('⚠️ Error fetching order items: $e');
      return [];
    }
  }
}
