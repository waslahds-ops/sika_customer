import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../core/utils/verification_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../../profile/domain/entities/profile_entities.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _orderNoteController = TextEditingController();
  final FocusNode _orderNoteFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(profileProvider);
      if (profileState.addresses.isEmpty) {
        ref.read(profileProvider.notifier).loadAddresses();
      }

      final cartState = ref.read(cartProvider);
      if (cartState.items.isNotEmpty && cartState.storeId != null) {
        ref.read(cartProvider.notifier).loadStoreDetails(cartState.storeId!);
      }
    });
  }

  @override
  void dispose() {
    _orderNoteController.dispose();
    _orderNoteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final profileState = ref.watch(profileProvider);
    final defaultAddress = _resolveDefaultAddress(profileState.addresses);

    return Scaffold(
      backgroundColor: AppPallete.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: cartState.items.isEmpty
                  ? _buildEmptyCart(context)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          _buildDeliveryTimeCard(context),
                          const SizedBox(height: 16),
                          _buildDeliveryFromCard(context),
                          const SizedBox(height: 16),
                          _buildDeliveryToCard(context, defaultAddress),
                          const SizedBox(height: 16),
                          _buildOrderNoteCard(context),
                          const SizedBox(height: 16),
                          _buildPaymentMethodCard(context, cartState),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
            ),
            _buildBottomBar(context, cartState, defaultAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              final goRouter = GoRouter.of(context);
              if (goRouter.canPop()) {
                goRouter.pop();
                return;
              }
              context.go('/main');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.checkout,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeCard(BuildContext context) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitleRow(
            context,
            AppLocalizations.of(context)!.deliveryTime,
            actionLabel: AppLocalizations.of(context)!.changeLabel,
            onAction: () => _showSnackBar(
              AppLocalizations.of(context)!.comingSoon,
              AppPallete.primaryYellowDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'In 35-60 minutes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryFromCard(BuildContext context) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitleRow(
            context,
            AppLocalizations.of(context)!.deliveryFrom,
            actionLabel: AppLocalizations.of(context)!.selectLabel,
            onAction: () => context.push('/addresses'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: AppPallete.success,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectAddress,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.deliveryFromSubtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryToCard(
    BuildContext context,
    AddressEntity? defaultAddress,
  ) {
    final label = defaultAddress?.label ??
        AppLocalizations.of(context)!.noDeliveryAddressSelected;
    final address = defaultAddress?.address ??
        AppLocalizations.of(context)!.deliveryToEmpty;

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitleRow(
            context,
            AppLocalizations.of(context)!.deliveryTo,
            actionLabel: AppLocalizations.of(context)!.selectLabel,
            onAction: () => context.push('/addresses'),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.map,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _focusOrderNoteField,
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/delivery-man_check.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.addDriverInstructions,
                  style: TextStyle(
                    color: AppPallete.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNoteCard(BuildContext context) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.yourOrder,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _orderNoteController,
            focusNode: _orderNoteFocusNode,
            maxLines: 4,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.yourOrderHint,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    CartState cartState,
  ) {
    final method = cartState.selectedPaymentMethod;
    final hasMethod = method != null;
    final methodLabel = method == PaymentMethod.card
        ? AppLocalizations.of(context)!.creditDebitCard
        : AppLocalizations.of(context)!.cashOnDelivery;
    final methodSubtitle = hasMethod
        ? (method == PaymentMethod.card
            ? AppLocalizations.of(context)!.payWithCardSecurely
            : AppLocalizations.of(context)!.payCashOnDeliverySubtitle)
        : AppLocalizations.of(context)!.selectPaymentMethodSubtitle;
    final iconData = method == PaymentMethod.card
        ? Icons.credit_card
        : Icons.attach_money;

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitleRow(
            context,
            AppLocalizations.of(context)!.paymentMethod,
            actionLabel: AppLocalizations.of(context)!.changeLabel,
            onAction: () => context.push('/payment-methods'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppPallete.success,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasMethod
                          ? methodLabel
                          : AppLocalizations.of(context)!.selectPaymentMethod,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      methodSubtitle,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CartState cartState,
    AddressEntity? defaultAddress,
  ) {
    final currencyFormatter =
        ref.read(countryCurrencyProvider.notifier);
    final totalLabel =
        currencyFormatter.formatConvertedPriceWithSymbolFromUsd(
      cartState.total,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.paymentMethod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: cartState.items.isEmpty
                  ? null
                  : () => _handlePlaceOrder(cartState, defaultAddress),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.placeOrder.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardTitleRow(
    BuildContext context,
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null) ...[
          _buildActionTag(actionLabel, onAction),
        ],
      ],
    );
  }

  Widget _buildActionTag(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppPallete.success),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPallete.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 88,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.cartEmpty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.addItemsToCart,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                AppLocalizations.of(context)!.startShopping,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AddressEntity? _resolveDefaultAddress(List<AddressEntity> addresses) {
    if (addresses.isEmpty) return null;
    try {
      return addresses.firstWhere((addr) => addr.isDefault);
    } catch (_) {
      return addresses.first;
    }
  }

  void _focusOrderNoteField() {
    if (!_orderNoteFocusNode.hasFocus) {
      _orderNoteFocusNode.requestFocus();
    }
  }

  Future<void> _handlePlaceOrder(
    CartState cartState,
    AddressEntity? defaultAddress,
  ) async {
    final cartItems = cartState.items;
    if (cartItems.isEmpty) return;

    if (cartState.selectedPaymentMethod == null) {
      _showSnackBar(
        AppLocalizations.of(context)!.pleaseSelectPaymentMethod,
        Colors.orange,
      );
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null || !user.isVerified) {
      final shouldVerify = await showVerificationRequiredDialog(context);
      if (shouldVerify == true && mounted) {
        context.push('/verification');
      }
      return;
    }

    if (defaultAddress == null) {
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.pleaseSelectDeliveryAddress,
          Colors.orange,
        );
        context.push('/addresses');
      }
      return;
    }

    final note = _orderNoteController.text.trim();
    final orderItems = cartItems.map((item) {
      final instructions = note.isNotEmpty
          ? note
          : (item.specialInstructions ?? '');
      return {
        'product_id': item.product.productId,
        'quantity': item.quantity,
        'price_at_order': item.product.price,
        'special_instructions': instructions,
      };
    }).toList();

    final created = await ref.read(ordersProvider.notifier).createOrder(
          storeId: cartState.storeId ?? cartItems.first.product.storeId,
          addressId: defaultAddress.addressId,
          items: orderItems,
        );

    if (!mounted) return;

    if (created != null) {
      ref.read(cartProvider.notifier).clearCart();
      _showSnackBar(
        AppLocalizations.of(context)!.orderPlacedSuccessfully,
        Colors.green,
      );

      context.go(
        '/order-confirmation',
        extra: {'orderId': created.orderId},
      );
      return;
    }

    final ordersState = ref.read(ordersProvider);
    var errorMessage = ordersState.errorMessage ?? 'Failed to place order';

    if (errorMessage.contains('product_id') &&
        errorMessage.contains('invalid')) {
      errorMessage =
          '❌ One or more products are no longer available. Remove them and try again.';
    } else if (errorMessage.contains('delivery_address')) {
      errorMessage = '❌ Please select a valid delivery address.';
    } else if (errorMessage.contains('payment_method')) {
      errorMessage = '❌ Please select a payment method.';
    }

    _showSnackBar(errorMessage, Colors.red);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
