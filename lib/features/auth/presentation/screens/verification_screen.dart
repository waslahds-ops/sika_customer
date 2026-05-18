import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';

import '../../../../core/constants/app_pallete.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../../injection_container.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String? email;
  final bool isPasswordReset;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    this.email,
    this.isPasswordReset = false,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final List<String> _code = ['', '', '', '', '', ''];
  int _currentIndex = 0;
  int _resendTimer = 50;
  Timer? _timer;
  bool _isVerifying = false; // Local loading state for button feedback
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _setupOTPListener();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messagingService.clearOTPCallback();
    super.dispose();
  }

  void _setupOTPListener() {
    _messagingService.setOTPReceivedCallback((code, data) {
      if (mounted) {
        _autoFillCode(code);

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ' ${AppLocalizations.of(context)!.verificationCodeReceived}: $code',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _autoFillCode(String code) {
    if (code.length == 6) {
      setState(() {
        for (int i = 0; i < 6; i++) {
          _code[i] = code[i];
        }
        _currentIndex = 5;
      });
    }
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onNumberPressed(String number) {
    if (_currentIndex < 6) {
      setState(() {
        _code[_currentIndex] = number;
        if (_currentIndex < 5) {
          _currentIndex++;
        }
      });
    }
  }

  void _onBackspace() {
    if (_currentIndex > 0 || _code[_currentIndex].isNotEmpty) {
      setState(() {
        if (_code[_currentIndex].isEmpty && _currentIndex > 0) {
          _currentIndex--;
        }
        _code[_currentIndex] = '';
      });
    }
  }

  Future<void> _onVerify() async {
    final code = _code.join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterComplete6DigitCode),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get phone number from widget or auth state
    final phoneNumber = widget.phoneNumber.isNotEmpty
        ? widget.phoneNumber
        : ref.read(authProvider).pendingPhoneNumber;

    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneNumberMissing),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Use different verification path based on flow type
      if (widget.isPasswordReset) {
        // For password reset: use verifyCode with password reset flag
        print('🔑 Password Reset Verification Flow');
        setState(() => _isVerifying = true);
        
        final success = await ref
            .read(authProvider.notifier)
            .verifyCode(code, isPasswordReset: true);

        setState(() => _isVerifying = false);

        if (!success) {
          if (mounted) {
            final errorMessage = ref.read(authProvider).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  errorMessage ??
                      AppLocalizations.of(context)!.verificationFailed,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.codeVerified),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to reset password screen
          context.push(
            '/reset-password?phoneNumber=${widget.phoneNumber}&email=${widget.email ?? ''}',
          );
        }
      } else {
        // For normal registration: use verifyOTP with phone number
        print('👤 Normal Verification Flow');
        await ref
            .read(authProvider.notifier)
            .verifyOTP(phoneNumber: phoneNumber, otp: code);

        // Debug: inspect authProvider state after verification to help diagnose
        // why Set Password might see no user. Only show in debug mode.
        if (kDebugMode) {
          final authState = ref.read(authProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Auth debug: isAuth=${authState.isAuthenticated} user=${authState.user != null} pendingCode=${authState.pendingVerificationCode != null}',
                ),
                backgroundColor: Colors.blueGrey,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.verificationSuccessful,
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Normal verification flow - go to set password screen (push to stack)
          context.push('/set-password');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage ?? AppLocalizations.of(context)!.verificationFailed,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onSkip() async {
    // Skip verification and go to main, but user won't be fully verified
    await ref.read(authProvider.notifier).skipVerification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.youCanVerifyLaterFromProfile,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      context.go('/main');
    }
  }

  Future<void> _onResend() async {
    if (_resendTimer > 0) return;

    // Get phone number from widget or auth state
    final phoneNumber = widget.phoneNumber.isNotEmpty
        ? widget.phoneNumber
        : ref.read(authProvider).pendingPhoneNumber;

    // Validate phone number before attempting to resend
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneNumberMissing),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Resend OTP to phone number
      await ref.read(authProvider.notifier).resendOTP(phoneNumber);

      if (mounted) {
        setState(() {
          _resendTimer = 50;
          _code.fillRange(0, 6, '');
          _currentIndex = 0;
        });
        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.codeResentSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage ?? AppLocalizations.of(context)!.failedToResendCode,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            if (widget.isPasswordReset) {
              context.go('/forgot-password');
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                AppLocalizations.of(context)!.verification,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                '${AppLocalizations.of(context)!.weHaveSentACodeTo} ',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // CODE Label and Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onResend,
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.resend,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _resendTimer == 0
                                ? AppPallete.primaryYellow
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        if (_resendTimer > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${AppLocalizations.of(context)!.ins} $_resendTimer${AppLocalizations.of(context)!.seconds}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Code Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => Container(
                    width: 48,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _code[index],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Verify Button
              _isVerifying
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppPallete.primaryYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: AppButtonLoader(size: 20)),
                    )
                  : CustomButton(
                      onPressed: _onVerify,
                      text: AppLocalizations.of(context)!.verify,
                      textStyles: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                      backgroundColor: AppPallete.primaryYellow,
                      borderColor: AppPallete.primaryYellow,
                    ),
              const SizedBox(height: 16),

              // Skip Button (only for normal registration, not password reset)
              if (!widget.isPasswordReset)
                TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    AppLocalizations.of(context)!.skipForNow,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.primaryTeal,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

              const SizedBox(height: 80),

              // Number Pad
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Row 1-3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NumberKey(
                          number: '1',
                          onPressed: () => _onNumberPressed('1'),
                        ),
                        _NumberKey(
                          number: '2',
                          letters: 'ABC',
                          onPressed: () => _onNumberPressed('2'),
                        ),
                        _NumberKey(
                          number: '3',
                          letters: 'DEF',
                          onPressed: () => _onNumberPressed('3'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 4-6
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NumberKey(
                          number: '4',
                          letters: 'GHI',
                          onPressed: () => _onNumberPressed('4'),
                        ),
                        _NumberKey(
                          number: '5',
                          letters: 'JKL',
                          onPressed: () => _onNumberPressed('5'),
                        ),
                        _NumberKey(
                          number: '6',
                          letters: 'MNO',
                          onPressed: () => _onNumberPressed('6'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 7-9
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NumberKey(
                          number: '7',
                          letters: 'PQRS',
                          onPressed: () => _onNumberPressed('7'),
                        ),
                        _NumberKey(
                          number: '8',
                          letters: 'TUV',
                          onPressed: () => _onNumberPressed('8'),
                        ),
                        _NumberKey(
                          number: '9',
                          letters: 'WXYZ',
                          onPressed: () => _onNumberPressed('9'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 0 and backspace
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 100, height: 50),
                        _NumberKey(
                          number: '0',
                          onPressed: () => _onNumberPressed('0'),
                        ),
                        SizedBox(
                          width: 100,
                          height: 50,
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: _onBackspace,
                              borderRadius: BorderRadius.circular(10),
                              child: const Center(
                                child: Icon(
                                  Icons.backspace_outlined,
                                  color: Color(0xFF1C1C1E),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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

class _NumberKey extends StatelessWidget {
  final String number;
  final String? letters;
  final VoidCallback onPressed;

  const _NumberKey({
    required this.number,
    this.letters,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 50,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1E),
                  height: 1,
                ),
              ),
              if (letters != null)
                Text(
                  letters!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
