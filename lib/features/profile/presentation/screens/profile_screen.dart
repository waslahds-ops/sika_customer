import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/constants/app_pallete.dart';
import 'package:sika_customer/core/providers/app_reload_provider.dart';
import 'package:sika_customer/core/providers/country_currency_provider.dart';
import 'package:sika_customer/core/providers/locale_provider.dart';
import 'package:sika_customer/core/widgets/custom_button.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import 'package:sika_customer/core/constants/country_currency_config.dart';
import '../../../../injection_container.dart';
import '../widgets/profile_shimmer_loader.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).getCurrentUser();
    });
  }

  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });
    try {
      await ref.read(authProvider.notifier).getCurrentUser();
    } catch (e) {
      debugPrint('Profile refresh failed: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: SafeArea(
          child: const ProfileShimmerLoader(),
        ),
      );
    }

    final user = authState.user;
    final userName =
        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim().isNotEmpty
            ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim()
            : user?.phoneNumber ?? AppLocalizations.of(context)!.sikaUser;
    final currentLanguageCode = ref.watch(localeProvider).languageCode;
    final currentLanguageLabel = _languageDisplayLabel(currentLanguageCode);

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            edgeOffset: MediaQuery.of(context).padding.top,
            color: AppPallete.primaryTeal,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header with user name and support icon
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (authState.isAuthenticated) {
                                    context.push('/edit-profile');
                                  } else {
                                    context.push('/login');
                                  }
                                },
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 24),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push('/support');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.headset_mic_outlined,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Vouchers, Wallet, and Orders Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
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
                        child: authState.isAuthenticated
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _buildTopCard(
                                      icon: '🎫',
                                      title: AppLocalizations.of(context)!.voucher,
                                      onTap: () {
                                        context.push('/vouchers');
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 60,
                                    color: Colors.grey[200],
                                  ),
                                  Expanded(
                                    child: _buildTopCard(
                                      icon: '💳',
                                      title: AppLocalizations.of(context)!.wallet,
                                      onTap: () {
                                        context.push('/wallet');
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 60,
                                    color: Colors.grey[200],
                                  ),
                                  Expanded(
                                    child: _buildTopCard(
                                      icon: '📦',
                                      title: AppLocalizations.of(context)!.orders,
                                      onTap: () {
                                        ref
                                                .read(
                                                  navigationIndexProvider.notifier,
                                                )
                                                .state =
                                            1;
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildTopCard(
                                      icon: '🎫',
                                      title: AppLocalizations.of(context)!.voucher,
                                      onTap: () {
                                        context.push('/login');
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 60,
                                    color: Colors.grey[200],
                                  ),
                                  Expanded(
                                    child: _buildTopCard(
                                      icon: '📦',
                                      title: AppLocalizations.of(context)!.orders,
                                      onTap: () {
                                        context.push('/login');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Menu Items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.favorite_outline,
                            title: AppLocalizations.of(context)!.myFavourites,
                            onTap: () {
                              if (authState.isAuthenticated) {
                                context.push('/favorites');
                              } else {
                                context.push('/login');
                              }
                            },
                          ),

                          const SizedBox(height: 1),
                          _buildMenuItem(
                            context,
                            icon: Icons.language,
                            title: AppLocalizations.of(context)!.language,
                            trailing: Text(
                              _languageDisplayLabel(currentLanguageLabel),
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            onTap: () {
                              _showLanguageDialog(context);
                            },
                          ),
                          const SizedBox(height: 1),
                          _buildMenuItem(
                            context,
                            icon: Icons.currency_exchange,
                            title: AppLocalizations.of(context)!.selectCurrency,
                            trailing: Text(
                              ref.watch(countryCurrencyProvider).currency ==
                                      Currency.lbp
                                  ? 'LBP'
                                  : 'USD',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            onTap: () {
                              final notifier = ref.read(
                                countryCurrencyProvider.notifier,
                              );
                              final current = ref
                                  .read(countryCurrencyProvider)
                                  .currency;
                              notifier.setCurrency(
                                current == Currency.lbp ? Currency.usd : Currency.lbp,
                              );
                            },
                          ),
                          const SizedBox(height: 1),
                          _buildMenuItem(
                            context,
                            icon: Icons.lock_outline,
                            title: AppLocalizations.of(context)!.passwordAndSecurity,
                            onTap: () {
                              if (authState.isAuthenticated) {
                                context.push('/password-management');
                              } else {
                                context.push('/login');
                              }
                            },
                          ),
                          const SizedBox(height: 1),
                          _buildMenuItem(
                            context,
                            icon: Icons.settings_outlined,
                            title: AppLocalizations.of(context)!.settings,
                            onTap: () {
                              context.push('/settings');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isRefreshing)
            const Positioned.fill(
              child: Material(
                color: Colors.white,
                child: SafeArea(
                  child: ProfileShimmerLoader(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopCard({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.black, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showLanguageDialog(BuildContext context) {
    // Initialize selected language from the current locale so the dialog
    // reflects the last chosen language.
    String selectedLanguage = ref.read(localeProvider).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.language,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),

              // Arabic option
              InkWell(
                onTap: () {
                  setState(() {
                    selectedLanguage = 'ar';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('العربية', style: TextStyle(fontSize: 16)),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedLanguage == 'ar'
                                ? Colors.black
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: selectedLanguage == 'ar'
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(),

              // English option
              InkWell(
                onTap: () {
                  setState(() {
                    selectedLanguage = 'en';
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('English', style: TextStyle(fontSize: 16)),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedLanguage == 'en'
                                ? Colors.black
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: selectedLanguage == 'en'
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Yes button
              CustomButton(
                onPressed: () async {
                  Navigator.pop(bottomSheetContext);
                  // Change language using locale provider
                  if (mounted) {
                    final localeNotifier = ref.read(localeProvider.notifier);
                    await localeNotifier.setLocale(Locale(selectedLanguage));

                    // Trigger app reload to show splash and apply language change
                    final reloadManager = ref.read(appReloadManagerProvider);
                    await reloadManager.triggerReload();
                  }
                },
                text: AppLocalizations.of(context)!.yes,
                textStyles: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                backgroundColor: AppPallete.primaryYellow,
                borderColor: AppPallete.primaryYellow,
                borderRadius: BorderRadius.circular(12),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _languageDisplayLabel(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }
}
