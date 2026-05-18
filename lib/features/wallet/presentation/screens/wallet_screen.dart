import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/core/utils/localization_helper.dart';
import 'package:sika_customer/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:sika_customer/features/wallet/presentation/widgets/balance_card.dart';
import 'package:sika_customer/features/wallet/presentation/widgets/transaction_item.dart';
import 'package:sika_customer/features/wallet/presentation/widgets/wallet_stats_widget.dart';


class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Load wallet data when screen initializes
    Future.microtask(() {
      ref.read(walletNotifierProvider.notifier).getWallet();
      ref.read(walletNotifierProvider.notifier).getTransactions();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreTransactions();
    }
  }

  void _loadMoreTransactions() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      await ref
          .read(walletNotifierProvider.notifier)
          .getTransactions(page: _currentPage);
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _navigateToTopUp() {
    Navigator.of(context).pushNamed('/wallet/topup');
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t(context, 'wallet')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(walletNotifierProvider.notifier).getWallet();
          await ref.read(walletNotifierProvider.notifier).getTransactions();
          _currentPage = 1;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Balance Card
                if (walletState.wallet != null)
                  BalanceCard(
                    wallet: walletState.wallet!,
                    onTopUpPressed: _navigateToTopUp,
                  )
                else if (walletState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (walletState.error != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          t(context, 'errorLoadingWallet'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(walletNotifierProvider.notifier)
                                .getWallet();
                          },
                          child: Text(t(context, 'retry')),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Stats Widget
                if (walletState.wallet != null)
                  WalletStatsWidget(wallet: walletState.wallet!),
                const SizedBox(height: 24),

                // Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t(context, 'recentTransactions'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (walletState.transactions.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/wallet/transactions');
                        },
                        child: Text(t(context, 'seeAll')),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Transaction List
                if (walletState.isRefreshing &&
                    walletState.transactions.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (walletState.transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        t(context, 'noTransactions'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: walletState.transactions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final transaction = walletState.transactions[index];
                      return TransactionItem(transaction: transaction);
                    },
                  ),

                // Load more indicator
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Error message if any
                if (walletState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              walletState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            onPressed: () {
                              ref
                                  .read(walletNotifierProvider.notifier)
                                  .clearError();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
