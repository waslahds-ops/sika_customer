import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/product.dart';
import '../../../../injection_container.dart';

enum AddItemResult { success, requiresVerification, conflict }

enum PaymentMethod { cash, card }

// Cart item model that wraps Product with quantity
class CartItem {
  final Product product;
  int quantity;
  final String? specialInstructions;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

// Cart state
class CartState {
  final List<CartItem> items;
  final int? storeId; // Track which store the cart belongs to
  final bool includesCutlery;
  final double? deliveryFeeFromServer; // Store dynamic delivery fee from server
  final String storeName; // Store name from server
  final String? appliedVoucherCode; // Applied voucher/promo code
  final double appliedDiscount; // Discount amount from voucher
  final double? voucherDiscountPercentage; // Discount percentage for display
  final double? voucherMaxSavings; // Max savings info for display
  final PaymentMethod?
  selectedPaymentMethod; // Selected payment method (cash or card)
  final Map<String, dynamic>?
  selectedCard; // Selected card details {id, lastFour, holderName, brand}

  CartState({
    this.items = const [],
    this.storeId,
    this.includesCutlery = true,
    this.deliveryFeeFromServer,
    this.storeName = 'Store',
    this.appliedVoucherCode,
    this.appliedDiscount = 0.0,
    this.voucherDiscountPercentage,
    this.voucherMaxSavings,
    this.selectedPaymentMethod,
    this.selectedCard,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  // Use server delivery fee if available, otherwise default to 5.0
  double get deliveryFee {
    return deliveryFeeFromServer ?? 5.0;
  }

  double get total => (subtotal + deliveryFee) - appliedDiscount;

  double get totalBeforeDiscount => subtotal + deliveryFee;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    int? storeId,
    bool clearStoreId = false,
    bool? includesCutlery,
    double? deliveryFeeFromServer,
    String? storeName,
    String? appliedVoucherCode,
    bool clearVoucher = false,
    double? appliedDiscount,
    double? voucherDiscountPercentage,
    double? voucherMaxSavings,
    PaymentMethod? selectedPaymentMethod,
    Map<String, dynamic>? selectedCard,
    bool clearSelectedCard = false,
  }) {
    return CartState(
      items: items ?? this.items,
      storeId: clearStoreId ? null : (storeId ?? this.storeId),
      includesCutlery: includesCutlery ?? this.includesCutlery,
      deliveryFeeFromServer:
          deliveryFeeFromServer ?? this.deliveryFeeFromServer,
      storeName: storeName ?? this.storeName,
      appliedVoucherCode: clearVoucher
          ? null
          : (appliedVoucherCode ?? this.appliedVoucherCode),
      appliedDiscount: clearVoucher
          ? 0.0
          : (appliedDiscount ?? this.appliedDiscount),
      voucherDiscountPercentage: clearVoucher
          ? null
          : (voucherDiscountPercentage ?? this.voucherDiscountPercentage),
      voucherMaxSavings: clearVoucher
          ? null
          : (voucherMaxSavings ?? this.voucherMaxSavings),
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedCard: clearSelectedCard
          ? null
          : (selectedCard ?? this.selectedCard),
    );
  }
}

// Cart notifier
class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;
  late final Box<dynamic> _cartBox;
  static const String _paymentMethodKey = 'selected_payment_method';
  static const String _selectedCardKey = 'selected_card';

  CartNotifier(this.ref) : super(CartState()) {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      _cartBox = Hive.box('cart_preferences');
      await _loadPaymentMethod();
    } catch (e) {
      debugPrint('❌ Error initializing Hive: $e');
    }
  }

  Future<void> _loadPaymentMethod() async {
    try {
      final savedMethod =
          _cartBox.get(_paymentMethodKey, defaultValue: null) as String?;
      final savedCard =
          _cartBox.get(_selectedCardKey, defaultValue: null) as Map?;

      if (savedMethod != null) {
        final paymentMethod = PaymentMethod.values.firstWhere(
          (e) => e.toString() == savedMethod,
        );
        final selectedCard = savedCard != null
            ? Map<String, dynamic>.from(savedCard)
            : null;

        state = state.copyWith(
          selectedPaymentMethod: paymentMethod,
          selectedCard: selectedCard,
        );
        debugPrint('✅ Payment method loaded: $paymentMethod');
      }
    } catch (e) {
      debugPrint('❌ Error loading payment method: $e');
    }
  }

  // Add item to cart
  AddItemResult addItem(
    Product product, {
    int quantity = 1,
    String? specialInstructions,
    bool force = false,
  }) {
    // Check if user is verified
    final user = ref.read(authProvider).user;
    if (user == null || !user.isVerified) {
      // Indicate verification required
      return AddItemResult.requiresVerification;
    }

    // Check if adding from different store
    if (state.storeId != null && state.storeId != product.storeId) {
      if (!force) {
        // Caller should confirm before clearing existing cart
        return AddItemResult.conflict;
      }

      // force == true => clear and continue
      state = CartState(items: [], storeId: product.storeId);
    }

    // Check if item already exists
    final existingIndex = state.items.indexWhere(
      (item) => item.product.productId == product.productId,
    );

    if (existingIndex != -1) {
      // Update quantity of existing item
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Add new item
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            product: product,
            quantity: quantity,
            specialInstructions: specialInstructions,
          ),
        ],
        storeId: product.storeId,
      );
    }

    return AddItemResult.success;
  }

  // Remove item from cart
  void removeItem(int productId) {
    final updatedItems = state.items
        .where((item) => item.product.productId != productId)
        .toList();

    state = state.copyWith(
      items: updatedItems,
      clearStoreId: updatedItems.isEmpty,
    );
  }

  // Update item quantity
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  // Increment quantity
  void incrementQuantity(int productId) {
    final item = state.items.firstWhere(
      (item) => item.product.productId == productId,
    );
    updateQuantity(productId, item.quantity + 1);
  }

  // Decrement quantity
  void decrementQuantity(int productId) {
    final item = state.items.firstWhere(
      (item) => item.product.productId == productId,
    );
    updateQuantity(productId, item.quantity - 1);
  }

  // Clear cart
  void clearCart() {
    state = CartState();
  }

  // Apply voucher/promo code
  void applyVoucher(
    String code, {
    double discountAmount = 0.0,
    double? discountPercentage,
    double? maxSavings,
  }) {
    // Calculate actual discount based on subtotal
    double finalDiscount = discountAmount;
    if (discountPercentage != null && discountPercentage > 0) {
      finalDiscount = (state.subtotal * discountPercentage) / 100;
      // Cap at maxSavings if provided
      if (maxSavings != null && finalDiscount > maxSavings) {
        finalDiscount = maxSavings;
      }
    }

    state = state.copyWith(
      appliedVoucherCode: code,
      appliedDiscount: finalDiscount,
      voucherDiscountPercentage: discountPercentage,
      voucherMaxSavings: maxSavings,
    );
  }

  // Remove applied voucher
  void removeVoucher() {
    state = state.copyWith(clearVoucher: true);
  }

  // Set payment method to cash
  Future<void> setPaymentMethodCash() async {
    try {
      // First update the state immediately for UI feedback
      state = state.copyWith(
        selectedPaymentMethod: PaymentMethod.cash,
        selectedCard: null,
        clearSelectedCard: true,
      );
      // Then persist to storage
      await _cartBox.put(_paymentMethodKey, PaymentMethod.cash.toString());
      debugPrint('✅ Payment method set to Cash');
    } catch (e) {
      debugPrint('❌ Error saving payment method: $e');
      // Revert on error
      state = state.copyWith(selectedPaymentMethod: null);
    }
  }

  // Set payment method to card
  Future<void> setPaymentMethodCard(Map<String, dynamic> cardDetails) async {
    try {
      // First update state for UI feedback
      state = state.copyWith(
        selectedPaymentMethod: PaymentMethod.card,
        selectedCard: cardDetails,
      );
      // Then persist to storage
      await _cartBox.put(_paymentMethodKey, PaymentMethod.card.toString());
      await _cartBox.put(_selectedCardKey, cardDetails);
      debugPrint('✅ Payment method set to Card: ${cardDetails['lastFour']}');
    } catch (e) {
      debugPrint('❌ Error saving card: $e');
      // Revert on error
      state = state.copyWith(
        selectedPaymentMethod: null,
        selectedCard: null,
        clearSelectedCard: true,
      );
    }
  }

  // Clear payment method
  Future<void> clearPaymentMethod() async {
    try {
      await _cartBox.delete(_paymentMethodKey);
      await _cartBox.delete(_selectedCardKey);
      state = state.copyWith(
        selectedPaymentMethod: null,
        selectedCard: null,
        clearSelectedCard: true,
      );
      debugPrint('✅ Payment method cleared');
    } catch (e) {
      debugPrint('❌ Error clearing payment method: $e');
    }
  }

  // Check if cart is ready for checkout (has payment method selected)
  bool isReadyForCheckout() {
    return state.selectedPaymentMethod != null;
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return state.items.any((item) => item.product.productId == productId);
  }

  // Get item quantity
  int getQuantity(int productId) {
    try {
      final item = state.items.firstWhere(
        (item) => item.product.productId == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Toggle cutlery option
  void toggleCutlery(bool value) {
    state = state.copyWith(includesCutlery: value);
  }

  // Load store details for cart display
  Future<void> loadStoreDetails(int storeId) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final store = await apiService.getStore(storeId);

      state = state.copyWith(
        storeName: store.name,
        deliveryFeeFromServer: store.deliveryFee.toDouble(),
      );
    } catch (e) {
      debugPrint('❌ Error loading store details: $e');
    }
  }
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
