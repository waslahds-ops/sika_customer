import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entities.dart';
import 'package:hive/hive.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
// import '../../domain/usecases/track_order_usecase.dart'; // Not available in customer API

// States
class OrdersState extends Equatable {
  final bool isLoading;
  final List<OrderEntity> inProgressOrders;
  final List<OrderEntity> completedOrders;
  final OrderEntity? selectedOrder;
  final List<OrderTrackingEntity> tracking;
  final String? errorMessage;
  final String? successMessage;

  OrdersState({
    this.isLoading = false,
    this.inProgressOrders = const [],
    this.completedOrders = const [],
    this.selectedOrder,
    this.tracking = const [],
    this.errorMessage,
    this.successMessage,
  });

  // Keep orders for backward compatibility
  List<OrderEntity> get orders => inProgressOrders;

  OrdersState copyWith({
    bool? isLoading,
    List<OrderEntity>? inProgressOrders,
    List<OrderEntity>? completedOrders,
    List<OrderEntity>? orders, // For backward compatibility
    OrderEntity? selectedOrder,
    List<OrderTrackingEntity>? tracking,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedOrder = false,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      inProgressOrders: inProgressOrders ?? (orders ?? this.inProgressOrders),
      completedOrders: completedOrders ?? this.completedOrders,
      selectedOrder: clearSelectedOrder
          ? null
          : (selectedOrder ?? this.selectedOrder),
      tracking: tracking ?? this.tracking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    inProgressOrders,
    completedOrders,
    selectedOrder,
    tracking,
    errorMessage,
    successMessage,
  ];
}

// Notifier
class OrdersNotifier extends StateNotifier<OrdersState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  // final TrackOrderUseCase trackOrderUseCase; // Not available in customer API

  late final Box<dynamic> _ordersBox;

  OrdersNotifier({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    // required this.trackOrderUseCase,
  }) : super(OrdersState()) {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      _ordersBox = Hive.box('ordersBox');
      await _loadLocalOrders();
    } catch (e) {
      print('❌ Error initializing orders Hive box: $e');
    }
  }

  Future<void> _loadLocalOrders() async {
    try {
      final localOrders =
          _ordersBox.get('orders', defaultValue: []) as List<dynamic>;
      if (localOrders.isNotEmpty) {
        // Convert stored maps back to OrderEntity objects
        final orders = localOrders.map((orderMap) {
          return OrderEntity.fromJson(Map<String, dynamic>.from(orderMap));
        }).toList();

        // Separate into in-progress and completed
        final inProgress = orders.where((order) => !order.isCompleted).toList();
        final completed = orders.where((order) => order.isCompleted).toList();

        state = state.copyWith(
          inProgressOrders: inProgress,
          completedOrders: completed,
          orders: orders,
        );
      }
    } catch (e) {
      print('❌ Error loading local orders: $e');
    }
  }

  Future<void> _saveOrderLocally(OrderEntity order) async {
    try {
      final currentOrders =
          _ordersBox.get('orders', defaultValue: []) as List<dynamic>;
      final orderMap = order.toJson();

      // Check if order already exists (avoid duplicates)
      final existingIndex = currentOrders.indexWhere(
        (o) => o['orderId'] == order.orderId,
      );
      if (existingIndex != -1) {
        currentOrders[existingIndex] = orderMap;
      } else {
        currentOrders.add(orderMap);
      }

      await _ordersBox.put('orders', currentOrders);
      print('✅ Order saved locally: ${order.orderId}');
    } catch (e) {
      print('❌ Error saving order locally: $e');
    }
  }

  // Get all local orders
  List<OrderEntity> getLocalOrders() {
    try {
      final localOrders =
          _ordersBox.get('orders', defaultValue: []) as List<dynamic>;
      return localOrders.map((orderMap) {
        return OrderEntity.fromJson(Map<String, dynamic>.from(orderMap));
      }).toList();
    } catch (e) {
      print('❌ Error getting local orders: $e');
      return [];
    }
  }

  // Clear all local orders
  Future<void> clearLocalOrders() async {
    try {
      await _ordersBox.delete('orders');
      state = OrdersState(); // Reset state
      print('✅ Local orders cleared');
    } catch (e) {
      print('❌ Error clearing local orders: $e');
    }
  }

  Future<OrderEntity?> createOrder({
    required int storeId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? promoCode,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await createOrderUseCase(
      CreateOrderParams(
        storeId: storeId,
        addressId: addressId,
        items: items,
        specialInstructions: specialInstructions,
        promoCode: promoCode,
      ),
    );

    OrderEntity? createdOrder;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (order) {
        // Add the newly created order to the list
        final updatedOrders = [order, ...state.orders];
        state = state.copyWith(
          isLoading: false,
          orders: updatedOrders,
          selectedOrder: order,
          successMessage: 'Order created successfully',
        );
        createdOrder = order;

        // Save order locally for offline access
        _saveOrderLocally(order);
      },
    );

    return createdOrder;
  }

  Future<void> createOrderFromCart(int addressId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    // This will be implemented when called from CartScreen
    // The actual order creation happens in the CartScreen button handler
  }

  Future<void> loadOrders({String? tab}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getOrdersUseCase(GetOrdersParams(tab: tab));

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (orders) {
        // Filter orders based on tab
        if (tab == 'completed') {
          final completed = orders.where((o) => o.isCompleted).toList();
          state = state.copyWith(isLoading: false, completedOrders: completed);
        } else if (tab == 'in_progress') {
          final inProgress = orders.where((o) => !o.isCompleted).toList();
          state = state.copyWith(isLoading: false, inProgressOrders: inProgress);
          // Cache "On The way" orders locally for quick access
          try {
            _cacheOnTheWayOrders(inProgress);
          } catch (e) {
            print('⚠️ Error caching on-the-way orders: $e');
          }
        } else {
          // No tab specified - set both in-progress and completed
          final inProgress = orders.where((o) => !o.isCompleted).toList();
          final completed = orders.where((o) => o.isCompleted).toList();
          state = state.copyWith(
            isLoading: false,
            inProgressOrders: inProgress,
            completedOrders: completed,
          );
        }
      },
    );
  }

  void _cacheOnTheWayOrders(List<OrderEntity> orders) {
    final box = Hive.box('appStateBox');
    final onTheWay = orders
        .where((o) {
          final s = o.status.toLowerCase();
          return s == 'out_for_delivery' ||
              s == 'picked_up' ||
              s == 'on_the_way';
        })
        .map((o) => _orderToMap(o))
        .toList();

    box.put('onTheWayOrders', onTheWay);
    print('💾 Cached ${onTheWay.length} on-the-way orders to appStateBox');
  }

  Map<String, dynamic> _orderToMap(OrderEntity o) {
    return {
      'orderId': o.orderId,
      'orderNumber': o.orderNumber,
      'storeId': o.storeId,
      'status': o.status,
      'totalAmount': o.totalAmount,
      'createdAt': o.createdAt.toIso8601String(),
      'deliveryAddress': o.deliveryAddress,
      'deliveryLatitude': o.deliveryLatitude,
      'deliveryLongitude': o.deliveryLongitude,
      'agentId': o.agentId,
      'agentName': o.agentName,
      'agentPhone': o.agentPhone,
      'agentVehicleType': o.agentVehicleType,
      'agentVehiclePlate': o.agentVehiclePlate,
      'canTrack': o.canTrack,
      'hasQrCode': o.hasQrCode,
      'qrCodeUrl': o.qrCodeUrl,
    };
  }

  Future<void> loadInProgressOrders() async {
    await loadOrders(tab: 'in_progress');
  }

  Future<void> loadCompletedOrders() async {
    await loadOrders(tab: 'completed');
  }

  // Not available in customer API - would need to implement via admin/merchant endpoints
  // Future<void> trackOrder(int orderId) async {
  //   state = state.copyWith(isLoading: true, clearError: true);
  //
  //   final result = await trackOrderUseCase(orderId);
  //
  //   result.fold(
  //     (failure) => state = state.copyWith(
  //       isLoading: false,
  //       errorMessage: _mapFailureToMessage(failure),
  //     ),
  //     (tracking) =>
  //         state = state.copyWith(isLoading: false, tracking: tracking),
  //   );
  // }

  void selectOrder(OrderEntity? order) {
    state = state.copyWith(
      selectedOrder: order,
      clearSelectedOrder: order == null,
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network.';
    } else if (failure is UnauthorizedFailure) {
      return 'Please log in to view your orders';
    } else if (failure is ForbiddenFailure) {
      return 'Account verification required. Please verify your phone number.';
    } else if (failure is NotFoundFailure) {
      return 'Order not found';
    }
    return 'Error: ${failure.message}';
  }
}
