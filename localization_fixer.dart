/// Script to help identify and fix hardcoded English strings
/// Run this to see all files and lines that need localization fixes
///
/// Hardcoded strings to replace (keep "Sika" and "English" as-is):

final hardcodedStringsMap = {
  // Settings & Account
  'Settings': 'accountSettings',
  'Log out': 'logout',
  'Log Out': 'logout',
  'Confirm log out?': 'logOutConfirm',
  'Cancel': 'cancel',
  'Delete Account': 'deleteAccount',
  'Are you sure you want to delete your account?': 'deleteAccountConfirm',

  // Cart & Orders
  'My Orders': 'myOrders',
  'My Cart': 'myCart',
  'Ongoing': 'ongoing',
  'History': 'history',
  'Replace cart items?': 'replaceCartItems',
  'Clear & Add': 'addNewItem',
  'Added to cart': 'addedToCart',
  'Add to Cart': 'addToCart',

  // Reviews & Ratings
  'Please select a rating': 'selectRating',
  'Review submitted successfully!': 'submitReview',
  'Write Review': 'writeReview',
  'Your Review': 'yourReview',

  // Favorites
  'Favorites': 'favorites_title',
  'No favorites yet': 'noFavorites',
  'Remove Favorite': 'removeFavorite',

  // Verification
  'Verification Required': 'verificationRequired',
  'Please verify your account to place orders': 'pleaseVerifyAccount',
  'Verify Now': 'verifyNow',
  'Later': 'cancel',

  // Addresses
  'Delete Address': 'deleteAddress',
  'Edit Address': 'editAddress',
  'Add Address': 'addAddress',
  'Edit': 'edit',
  'Delete': 'delete',
  'Save': 'save',

  // Payment
  'Delete Card?': 'deleteAddress', // Similar confirmation
  'Card removed successfully': 'success',
  'Payment': 'payment',
  'Select Payment Method': 'selectPaymentMethod',

  // Wallet
  'Wallet': 'wallet',
  'Top Up': 'topUp',
  'Top up successful!': 'topUpSuccessful',

  // Notifications
  'Notifications': 'notifications',

  // Location
  'Location permission denied': 'locationPermissionDenied',
  'Location not found': 'locationNotFound',
  'Please select a location': 'selectLocation',

  // Error Messages
  'No results found': 'noResults',
  'Error': 'error',
  'Success': 'success',
  'Please fill in all fields': 'required',
  'Invalid promo code': 'invalidInput',

  // Other
  'FAQs': 'about', // Keep "Sika" brand name
  'NetCheck': 'NetCheck', // Keep as-is (app feature)
  'Clear cache': 'Clear cache', // Keep as-is (technical)
};

/// These SHOULD NOT be translated (brand/technical names):
final doNotTranslate = [
  'Sika',
  'English',
  'NetCheck',
  'Clear cache',
  'Firebase',
  'Google',
  'Facebook',
  'Apple',
];

/// Example usage in files - replace:
///
/// BEFORE:
/// ```dart
/// const Text('My Orders')
/// ```
///
/// AFTER:
/// ```dart
/// Text(AppLocalizations.of(context)!.myOrders)
/// ```
///
/// STEPS TO FIX ALL FILES:
/// 1. Add import: import '../../../../l10n/app_localizations.dart';
/// 2. In Widget build method, add: final l10n = AppLocalizations.of(context)!;
/// 3. Replace: Text('string') → Text(l10n.keyName)
/// 4. Replace: const Text('string') → Text(l10n.keyName)
/// 5. Replace: 'string', → l10n.keyName,
/// 6. Replace in SnackBars: Text('string') → Text(l10n.keyName)

void main() {
  print('=== Hardcoded Strings Mapping ===');
  hardcodedStringsMap.forEach((english, key) {
    print('$english → l10n.$key');
  });
}
