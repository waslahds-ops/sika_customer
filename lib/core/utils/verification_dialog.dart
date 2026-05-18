import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_pallete.dart';
import '../../l10n/app_localizations.dart';

/// Shows a dialog prompting the user to verify their account
/// Returns true if user chooses to verify, false otherwise
Future<bool?> showVerificationRequiredDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,

    //? TODO: Localizations
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context)!.verificationRequired),
      content: Text(
        AppLocalizations.of(context)!.youNeedToVerifyYourAccountBeforeYouCanAddItemsToCartOrPlaceOrders,
      ),
      actions: [
        //? TODO: Localizations
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(AppLocalizations.of(context)!.later),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppPallete.primaryTeal,
          ),
          onPressed: () => Navigator.pop(context, true),

          //? TODO: Localizations
          child: Text(AppLocalizations.of(context)!.verifyNow),
        ),
      ],
    ),
  );
}

/// Shows a snackbar indicating verification is required
void showVerificationRequiredSnackbar(
  BuildContext context, {
  String? phoneNumber,
  String? email,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    //? TODO: Localizations
    SnackBar(
      content: Text(AppLocalizations.of(context)!.pleaseVerifyYourAccountToPlaceOrders),
      backgroundColor: AppPallete.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.verify,
        textColor: Colors.white,
        onPressed: () {
          final params = <String, String>{};
          if (phoneNumber != null && phoneNumber.isNotEmpty) {
            params['phoneNumber'] = phoneNumber;
          }
          if (email != null && email.isNotEmpty) {
            params['email'] = email;
          }

          final uri = Uri(
            path: '/verification',
            queryParameters: params.isEmpty ? null : params,
          );
          context.push(uri.toString());
        },
      ),
    ),
  );
}
