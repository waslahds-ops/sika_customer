import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/core/utils/localization_helper.dart';
import 'package:sika_customer/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:sika_customer/l10n/app_localizations.dart';

class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  late TextEditingController _amountController;
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  final List<double> _presetAmounts = [10, 25, 50, 100];
  final List<_PaymentMethod> _paymentMethods = [
    _PaymentMethod(id: 'card', name: 'Credit Card', icon: Icons.credit_card),
    _PaymentMethod(
      id: 'bank',
      name: 'Bank Transfer',
      icon: Icons.account_balance,
    ),
    _PaymentMethod(id: 'apple_pay', name: 'Apple Pay', icon: Icons.apple),
    _PaymentMethod(id: 'google_pay', name: 'Google Pay', icon: Icons.payment),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toString();
  }

  void _processTopUp() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t(context, 'enterValidAmount'))));
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, 'selectPaymentMethod'))),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await ref
          .read(walletNotifierProvider.notifier)
          .topUpWallet(
            amount: amount,
            paymentMethodId: _selectedPaymentMethod!,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t(context, 'topUpSuccessful')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, 'topUpWallet')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Section
              Text(
                t(context, 'enterAmount'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // Preset Amounts
              Text(
                t(context, 'quickSelect'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetAmounts
                    .map(
                      (amount) => ChipButton(
                        label: '\$${amount.toInt()}',
                        onPressed: () => _setAmount(amount),
                        isSelected:
                            _amountController.text == amount.toStringAsFixed(0),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),

              // Payment Method Section
              Text(
                t(context, 'paymentMethod'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  final isSelected = _selectedPaymentMethod == method.id;

                  return PaymentMethodCard(
                    method: method,
                    isSelected: isSelected,
                    onSelected: () {
                      setState(() => _selectedPaymentMethod = method.id);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t(context, 'amount')),
                        Text(
                          '\$${_amountController.text.isEmpty ? '0.00' : _amountController.text}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t(context, 'fee')),
                        const Text(
                          '\$0.00',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t(context, 'total'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${_amountController.text.isEmpty ? '0.00' : _amountController.text}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF6B5FFF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Top Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processTopUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6B5FFF),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          t(context, 'proceedTopUp'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(t(context, 'cancel')),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const ChipButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6B5FFF),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6B5FFF) : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PaymentMethod {
  final String id;
  final String name;
  final IconData icon;

  _PaymentMethod({required this.id, required this.name, required this.icon});
}

class PaymentMethodCard extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final VoidCallback onSelected;

  const PaymentMethodCard({
    Key? key,
    required this.method,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF6B5FFF) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? const Color(0xFF6B5FFF).withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              color: isSelected
                  ? const Color(0xFF6B5FFF)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF6B5FFF) : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF6B5FFF)),
          ],
        ),
      ),
    );
  }
}

