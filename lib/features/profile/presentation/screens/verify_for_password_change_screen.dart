import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../injection_container.dart';

class VerifyForPasswordChangeScreen extends ConsumerStatefulWidget {
  const VerifyForPasswordChangeScreen({super.key});

  @override
  ConsumerState<VerifyForPasswordChangeScreen> createState() =>
      _VerifyForPasswordChangeScreenState();
}

class _VerifyForPasswordChangeScreenState
    extends ConsumerState<VerifyForPasswordChangeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
  }

  Future<void> _sendOTP() async {
    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user == null || user.phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.userPhoneNumberNotFound,
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Send OTP to user's phone
      await ref.read(authProvider.notifier).sendOTP(user.phoneNumber);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.verificationCodeSent} ${user.phoneNumber}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.failedToSendOTP} ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToVerification() async {
    final authState = ref.read(authProvider);
    final user = authState.user;

    if (user == null || user.phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.userPhoneNumberNotFound,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      context.push(
        '/verification',
        extra: {'phoneNumber': user.phoneNumber, 'isPasswordReset': false},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.verifyYourIdentity,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppPallete.primaryYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: 40,
                    color: AppPallete.primaryYellow,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                AppLocalizations.of(context)!.verifyYourPhoneNumber,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                AppLocalizations.of(context)!.verificationCodeSentDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Phone Number Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_outlined, color: AppPallete.primaryYellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.phoneNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.phoneNumber ??
                                AppLocalizations.of(context)!.unknown,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomButton(
                  onPressed: () {
                    if (!_isLoading) {
                      // Navigate to OTP verification screen
                      _navigateToVerification();
                    }
                  },
                  text: AppLocalizations.of(context)!.continueText,
                  textStyles: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  backgroundColor: AppPallete.primaryYellow,
                  borderColor: AppPallete.primaryYellow,
                ),
              ),

              const SizedBox(height: 16),

              // Resend Button
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: Text(
                    AppLocalizations.of(context)!.resendCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppPallete.primaryYellow,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.standardMessageRatesApply,
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
