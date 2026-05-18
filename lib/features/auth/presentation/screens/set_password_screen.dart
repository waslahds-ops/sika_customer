import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../injection_container.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Check if user is verified
        final authState = ref.read(authProvider);

        // ✅ TRUE - Verification successful, allow password submission
        if (authState.pendingVerificationCode != null ||
            (authState.pendingUserId != null && authState.pendingUserId! > 0) ||
            (authState.pendingEmail != null &&
                authState.pendingEmail!.isNotEmpty) ||
            (authState.pendingPhoneNumber != null &&
                authState.pendingPhoneNumber!.isNotEmpty)) {
          print('✅ Verification Status: TRUE - Proceeding with password reset');
          print(
            '   Verification Code: ${authState.pendingVerificationCode != null ? "✅ Available" : "❌ Missing"}',
          );
          print('   User ID: ${authState.pendingUserId}');

          // Use auth notifier to reset password using pending identifier/code
          try {
            await ref
                .read(authProvider.notifier)
                .resetPassword(newPassword: _passwordController.text);

            final err = ref.read(authProvider).errorMessage;
            if (err != null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${AppLocalizations.of(context)!.failedToSetPassword}: $err',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              setState(() => _isLoading = false);
              return;
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.passwordSetSuccessfully,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // After reset, navigate to login
              context.go('/login');
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context)!.failedToSetPassword}: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
          return;
        }

        // ❌ FALSE - Verification failed, don't send password
        print('❌ Verification Status: FALSE - Password submission blocked');
        print('   Pending Code: ${authState.pendingVerificationCode}');
        print('   Pending User ID: ${authState.pendingUserId}');
        print('   Pending Email: ${authState.pendingEmail}');
        print('   Pending Phone: ${authState.pendingPhoneNumber}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.mustCompleteVerificationBeforeSettingPassword,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSkip() {
    // Skip password setup for now
    context.go('/main');
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  AppLocalizations.of(context)!.setPassword,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  AppLocalizations.of(context)!.setPasswordSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Verification Status Indicator
                Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authProvider);

                    // Check verification status
                    final isVerified =
                        authState.pendingVerificationCode != null ||
                        (authState.pendingUserId != null &&
                            authState.pendingUserId! > 0) ||
                        (authState.pendingEmail != null &&
                            authState.pendingEmail!.isNotEmpty) ||
                        (authState.pendingPhoneNumber != null &&
                            authState.pendingPhoneNumber!.isNotEmpty);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isVerified
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isVerified ? Icons.check_circle : Icons.cancel,
                            color: isVerified ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isVerified
                                  ? AppLocalizations.of(
                                      context,
                                    )!.verifiedSuccessfully
                                  : AppLocalizations.of(
                                      context,
                                    )!.notVerifiedPleaseCompleteVerification,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isVerified
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.passwordMainRequirements,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirementItem(
                        AppLocalizations.of(context)!.atLeast8Characters,
                      ),
                      _buildRequirementItem(
                        AppLocalizations.of(context)!.oneUppercaseLetter,
                      ),
                      _buildRequirementItem(
                        AppLocalizations.of(context)!.oneLowercaseLetter,
                      ),
                      _buildRequirementItem(
                        AppLocalizations.of(context)!.oneNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppPallete.primaryYellow,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.pleaseEnterPassword;
                          }
                          if (value.length < 8) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordMustBeAtLeast8Characters;
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordMustContainUppercase;
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordMustContainLowercase;
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordMustContainNumber;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppPallete.primaryYellow,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                            child: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.pleaseConfirmPassword;
                          }
                          if (value != _passwordController.text) {
                            return AppLocalizations.of(
                              context,
                            )!.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryYellow,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[600]!,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.confirm,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Skip button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleSkip,
                    child: Text(
                      AppLocalizations.of(context)!.skipForNow,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
