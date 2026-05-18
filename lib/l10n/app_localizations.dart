import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sika'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'DELIVER TO'**
  String get deliverTo;

  /// No description provided for @searchDishesStores.
  ///
  /// In en, this message translates to:
  /// **'Search dishes, stores'**
  String get searchDishesStores;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @openStores.
  ///
  /// In en, this message translates to:
  /// **'Open Stores'**
  String get openStores;

  /// No description provided for @closedStores.
  ///
  /// In en, this message translates to:
  /// **'Closed Stores'**
  String get closedStores;

  /// No description provided for @popularNearYou.
  ///
  /// In en, this message translates to:
  /// **'Popular Near You'**
  String get popularNearYou;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get orderNumber;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlaced;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get orderConfirmed;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get ready;

  /// No description provided for @pickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get pickedUp;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @buyAgain.
  ///
  /// In en, this message translates to:
  /// **'Buy Again'**
  String get buyAgain;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @editItems.
  ///
  /// In en, this message translates to:
  /// **'EDIT ITEMS'**
  String get editItems;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY ADDRESS'**
  String get deliveryAddress;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'PLACE ORDER'**
  String get placeOrder;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Removed from cart'**
  String get removedFromCart;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start adding items to your cart'**
  String get startShopping;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Changing Language...'**
  String get changingLanguage;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW ADDRESS'**
  String get addNewAddress;

  /// No description provided for @noAddresses.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get noAddresses;

  /// No description provided for @addFirstAddress.
  ///
  /// In en, this message translates to:
  /// **'Add your first address to get started'**
  String get addFirstAddress;

  /// No description provided for @home_address.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_address;

  /// No description provided for @work_address.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work_address;

  /// No description provided for @other_address.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other_address;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// No description provided for @selectFromMap.
  ///
  /// In en, this message translates to:
  /// **'Select from Map'**
  String get selectFromMap;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @label.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get creditCard;

  /// No description provided for @savedCards.
  ///
  /// In en, this message translates to:
  /// **'Saved Cards'**
  String get savedCards;

  /// No description provided for @addNewCard.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolder;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @favorites_title.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites_title;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @startAddingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Start adding your favorite restaurants'**
  String get startAddingFavorites;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove Favorite'**
  String get removeFavorite;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove this restaurant from your favorites?'**
  String get removeFromFavorites;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Account'**
  String get verifyAccount;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to'**
  String get enterVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Delivery Time'**
  String get deliveryTime;

  /// No description provided for @estimatedArrivalWindow.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival window'**
  String get estimatedArrivalWindow;

  /// No description provided for @deliveryFrom.
  ///
  /// In en, this message translates to:
  /// **'Delivery From'**
  String get deliveryFrom;

  /// No description provided for @deliveryFromSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a saved delivery address or create a new one to place your order'**
  String get deliveryFromSubtitle;

  /// No description provided for @deliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Delivery To'**
  String get deliveryTo;

  /// No description provided for @noDeliveryAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'No delivery address selected'**
  String get noDeliveryAddressSelected;

  /// No description provided for @deliveryToEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address so we know where to send your order'**
  String get deliveryToEmpty;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectLabel;

  /// No description provided for @changeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLabel;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// No description provided for @addDriverInstructions.
  ///
  /// In en, this message translates to:
  /// **'Add Driver Instructions'**
  String get addDriverInstructions;

  /// No description provided for @yourOrder.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get yourOrder;

  /// No description provided for @yourOrderHint.
  ///
  /// In en, this message translates to:
  /// **'what do you want to send?'**
  String get yourOrderHint;

  /// No description provided for @selectPaymentMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the payment method you prefer'**
  String get selectPaymentMethodSubtitle;

  /// No description provided for @payWithCardSecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay with a saved card securely'**
  String get payWithCardSecurely;

  /// No description provided for @payCashOnDeliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay cash on delivery'**
  String get payCashOnDeliverySubtitle;

  /// No description provided for @cartOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {You have 1 order in the cart.} other {You have {count} orders in the cart.}}'**
  String cartOrdersMessage(num count);

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @anyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Any instructions?'**
  String get anyInstructions;

  /// No description provided for @instructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Write your preferences...'**
  String get instructionsHint;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// No description provided for @minOrder.
  ///
  /// In en, this message translates to:
  /// **'Min Order'**
  String get minOrder;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to Cart'**
  String get addedToCart;

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Item added to cart successfully'**
  String get itemAddedToCart;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get pleaseLoginFirst;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @back2Top.
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get back2Top;

  /// No description provided for @deliverYourStuff.
  ///
  /// In en, this message translates to:
  /// **'Deliver Your Stuff'**
  String get deliverYourStuff;

  /// No description provided for @buySomething.
  ///
  /// In en, this message translates to:
  /// **'Buy Something'**
  String get buySomething;

  /// No description provided for @hugeAppliances.
  ///
  /// In en, this message translates to:
  /// **'Huge Appliances'**
  String get hugeAppliances;

  /// No description provided for @truckEvacuatingCar.
  ///
  /// In en, this message translates to:
  /// **'Truck Evacuating Car'**
  String get truckEvacuatingCar;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterFirstName;

  /// No description provided for @pleaseEnterLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterLastName;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @accountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Account Not Verified'**
  String get accountNotVerified;

  /// No description provided for @verifyToPlaceOrders.
  ///
  /// In en, this message translates to:
  /// **'Verify to place orders'**
  String get verifyToPlaceOrders;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @pleaseVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Please verify your account to place orders'**
  String get pleaseVerifyAccount;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlacedSuccessfully;

  /// No description provided for @pleaseSelectAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select a delivery address'**
  String get pleaseSelectAddress;

  /// No description provided for @orderCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get orderCreatedSuccessfully;

  /// No description provided for @addressCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address created successfully'**
  String get addressCreatedSuccessfully;

  /// No description provided for @addressUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address updated successfully'**
  String get addressUpdatedSuccessfully;

  /// No description provided for @addressDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Address deleted successfully'**
  String get addressDeletedSuccessfully;

  /// No description provided for @defaultAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default address updated'**
  String get defaultAddressUpdated;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon!'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening!'**
  String get goodEvening;

  /// No description provided for @hey.
  ///
  /// In en, this message translates to:
  /// **'Hey'**
  String get hey;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get pleaseTryAgain;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirm;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @replaceCartItems.
  ///
  /// In en, this message translates to:
  /// **'Replace cart items?'**
  String get replaceCartItems;

  /// No description provided for @replaceCartItemsContent.
  ///
  /// In en, this message translates to:
  /// **'Your cart contains items from another store. Clear cart and add these items?'**
  String get replaceCartItemsContent;

  /// No description provided for @messageSentToAgent.
  ///
  /// In en, this message translates to:
  /// **'Message sent to delivery agent'**
  String get messageSentToAgent;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message to delivery agent'**
  String get failedToSendMessage;

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @selectRating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get selectRating;

  /// No description provided for @enterVerificationCodeFull.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete 6-digit code'**
  String get enterVerificationCodeFull;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code has expired'**
  String get codeExpired;

  /// No description provided for @resendCodeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully'**
  String get resendCodeSuccess;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @free_delivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get free_delivery;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @cuisines.
  ///
  /// In en, this message translates to:
  /// **'Cuisines'**
  String get cuisines;

  /// No description provided for @searchForStores.
  ///
  /// In en, this message translates to:
  /// **'Search for stores, cuisines...'**
  String get searchForStores;

  /// No description provided for @enterPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get enterPromoCode;

  /// No description provided for @applyPromo.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPromo;

  /// No description provided for @promoCode.
  ///
  /// In en, this message translates to:
  /// **'Promo Code'**
  String get promoCode;

  /// No description provided for @addItems.
  ///
  /// In en, this message translates to:
  /// **'Add Items'**
  String get addItems;

  /// No description provided for @selectItems.
  ///
  /// In en, this message translates to:
  /// **'Select Items'**
  String get selectItems;

  /// No description provided for @selectQuantity.
  ///
  /// In en, this message translates to:
  /// **'Select Quantity'**
  String get selectQuantity;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @allergyInfo.
  ///
  /// In en, this message translates to:
  /// **'Allergy Information'**
  String get allergyInfo;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @trackingOrder.
  ///
  /// In en, this message translates to:
  /// **'Tracking Order'**
  String get trackingOrder;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// No description provided for @deliveryEstimate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Estimate'**
  String get deliveryEstimate;

  /// No description provided for @driverLocation.
  ///
  /// In en, this message translates to:
  /// **'Driver Location'**
  String get driverLocation;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// No description provided for @messageDriver.
  ///
  /// In en, this message translates to:
  /// **'Message Driver'**
  String get messageDriver;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a payment method'**
  String get selectPaymentMethod;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @selectCard.
  ///
  /// In en, this message translates to:
  /// **'Select Card'**
  String get selectCard;

  /// No description provided for @enterCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Card Details'**
  String get enterCardDetails;

  /// No description provided for @expiryDateFormat.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDateFormat;

  /// No description provided for @saveForFutureUse.
  ///
  /// In en, this message translates to:
  /// **'Save for future use'**
  String get saveForFutureUse;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get securePayment;

  /// No description provided for @processPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get processPayment;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @selectAllergy.
  ///
  /// In en, this message translates to:
  /// **'Select Allergy'**
  String get selectAllergy;

  /// No description provided for @dietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get dietary;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @glutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten Free'**
  String get glutenFree;

  /// No description provided for @noNuts.
  ///
  /// In en, this message translates to:
  /// **'No Nuts'**
  String get noNuts;

  /// No description provided for @halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get halal;

  /// No description provided for @kosher.
  ///
  /// In en, this message translates to:
  /// **'Kosher'**
  String get kosher;

  /// No description provided for @noSpicy.
  ///
  /// In en, this message translates to:
  /// **'No Spicy'**
  String get noSpicy;

  /// No description provided for @addSpecialRequest.
  ///
  /// In en, this message translates to:
  /// **'Add Special Request'**
  String get addSpecialRequest;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsCount;

  /// No description provided for @deliveryCharge.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge'**
  String get deliveryCharge;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service Fee'**
  String get serviceFee;

  /// No description provided for @tipDriver.
  ///
  /// In en, this message translates to:
  /// **'Tip Driver'**
  String get tipDriver;

  /// No description provided for @tipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip Amount'**
  String get tipAmount;

  /// No description provided for @noCash.
  ///
  /// In en, this message translates to:
  /// **'No Cash'**
  String get noCash;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No Change'**
  String get noChange;

  /// No description provided for @changeAmount.
  ///
  /// In en, this message translates to:
  /// **'Change Amount'**
  String get changeAmount;

  /// No description provided for @paymentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmation'**
  String get paymentConfirmation;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// No description provided for @refundInitiated.
  ///
  /// In en, this message translates to:
  /// **'Refund Initiated'**
  String get refundInitiated;

  /// No description provided for @refundPending.
  ///
  /// In en, this message translates to:
  /// **'Refund Pending'**
  String get refundPending;

  /// No description provided for @refundCompleted.
  ///
  /// In en, this message translates to:
  /// **'Refund Completed'**
  String get refundCompleted;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report Problem'**
  String get reportProblem;

  /// No description provided for @problemType.
  ///
  /// In en, this message translates to:
  /// **'Problem Type'**
  String get problemType;

  /// No description provided for @wrongItems.
  ///
  /// In en, this message translates to:
  /// **'Wrong Items'**
  String get wrongItems;

  /// No description provided for @damageFood.
  ///
  /// In en, this message translates to:
  /// **'Damaged Food'**
  String get damageFood;

  /// No description provided for @missingItems.
  ///
  /// In en, this message translates to:
  /// **'Missing Items'**
  String get missingItems;

  /// No description provided for @coldFood.
  ///
  /// In en, this message translates to:
  /// **'Cold Food'**
  String get coldFood;

  /// No description provided for @incompleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Order'**
  String get incompleteOrder;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describeProblem;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get reportSubmitted;

  /// No description provided for @weWillAssist.
  ///
  /// In en, this message translates to:
  /// **'We will assist you shortly'**
  String get weWillAssist;

  /// No description provided for @browseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse Menu'**
  String get browseMenu;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More Info'**
  String get moreInfo;

  /// No description provided for @lessInfo.
  ///
  /// In en, this message translates to:
  /// **'Less Info'**
  String get lessInfo;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @pleasePatienceLoading.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we load...'**
  String get pleasePatienceLoading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Empty List'**
  String get emptyList;

  /// No description provided for @trySearching.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else'**
  String get trySearching;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get invalidInput;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// No description provided for @termsAccepted.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get termsAccepted;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms and conditions'**
  String get agreeToTerms;

  /// No description provided for @privacyAccepted.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Privacy Policy'**
  String get privacyAccepted;

  /// No description provided for @agreeToPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the privacy policy'**
  String get agreeToPrivacy;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @earnPoints.
  ///
  /// In en, this message translates to:
  /// **'Earn Points'**
  String get earnPoints;

  /// No description provided for @preOrder.
  ///
  /// In en, this message translates to:
  /// **'pre-order'**
  String get preOrder;

  /// No description provided for @ratingAndReviews.
  ///
  /// In en, this message translates to:
  /// **'Rating & reviews'**
  String get ratingAndReviews;

  /// No description provided for @aisles.
  ///
  /// In en, this message translates to:
  /// **'Aisles'**
  String get aisles;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy Address'**
  String get copyAddress;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share Location'**
  String get shareLocation;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @navigateTo.
  ///
  /// In en, this message translates to:
  /// **'Navigate To'**
  String get navigateTo;

  /// No description provided for @closeStore.
  ///
  /// In en, this message translates to:
  /// **'Store Closed'**
  String get closeStore;

  /// No description provided for @storeWillOpenAt.
  ///
  /// In en, this message translates to:
  /// **'Store will open at'**
  String get storeWillOpenAt;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @saleBadge.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get saleBadge;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @popularBadge.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularBadge;

  /// No description provided for @trendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trendingBadge;

  /// No description provided for @bestSellerBadge.
  ///
  /// In en, this message translates to:
  /// **'Best Seller'**
  String get bestSellerBadge;

  /// No description provided for @limitedTime.
  ///
  /// In en, this message translates to:
  /// **'Limited Time'**
  String get limitedTime;

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get expiresIn;

  /// No description provided for @noStoresFound.
  ///
  /// In en, this message translates to:
  /// **'No Stores Found'**
  String get noStoresFound;

  /// No description provided for @tryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another search'**
  String get tryAnotherSearch;

  /// No description provided for @enterAtLeastCharacters.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters'**
  String get enterAtLeastCharacters;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @yourWallet.
  ///
  /// In en, this message translates to:
  /// **'Your Wallet'**
  String get yourWallet;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUp;

  /// No description provided for @topUpWallet.
  ///
  /// In en, this message translates to:
  /// **'Top Up Wallet'**
  String get topUpWallet;

  /// No description provided for @topUpSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Top up successful!'**
  String get topUpSuccessful;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @balanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceAfter;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @quickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick Select'**
  String get quickSelect;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @proceedTopUp.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Top Up'**
  String get proceedTopUp;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @errorLoadingWallet.
  ///
  /// In en, this message translates to:
  /// **'Error loading wallet'**
  String get errorLoadingWallet;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @noInProgressOrders.
  ///
  /// In en, this message translates to:
  /// **'No in progress orders'**
  String get noInProgressOrders;

  /// No description provided for @noCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'No completed orders'**
  String get noCompletedOrders;

  /// No description provided for @confirmDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery address'**
  String get confirmDeliveryAddress;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @codeVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified! Proceed to reset password.'**
  String get codeVerified;

  /// No description provided for @enterVoucherCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a voucher code'**
  String get enterVoucherCode;

  /// No description provided for @invalidOrExpiredVoucher.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired voucher code'**
  String get invalidOrExpiredVoucher;

  /// No description provided for @errorOpening.
  ///
  /// In en, this message translates to:
  /// **'Error opening'**
  String get errorOpening;

  /// No description provided for @preferenceSet.
  ///
  /// In en, this message translates to:
  /// **'Preference set'**
  String get preferenceSet;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code'**
  String get invalidPromoCode;

  /// No description provided for @enterComplete6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete 6-digit code'**
  String get enterComplete6DigitCode;

  /// No description provided for @updateAddress.
  ///
  /// In en, this message translates to:
  /// **'Update address'**
  String get updateAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddress;

  /// No description provided for @cardAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAddedSuccessfully;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification successful'**
  String get verificationSuccessful;

  /// No description provided for @codeResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Code resent successfully'**
  String get codeResentSuccessfully;

  /// No description provided for @voucherRemoved.
  ///
  /// In en, this message translates to:
  /// **'Voucher removed'**
  String get voucherRemoved;

  /// No description provided for @deleteAddressConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get deleteAddressConfirmation;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete Card?'**
  String get deleteCard;

  /// No description provided for @cardRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Card removed successfully'**
  String get cardRemovedSuccessfully;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @deliveryAgent.
  ///
  /// In en, this message translates to:
  /// **'Delivery Agent'**
  String get deliveryAgent;

  /// No description provided for @trackDriver.
  ///
  /// In en, this message translates to:
  /// **'Track Driver'**
  String get trackDriver;

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driverName;

  /// No description provided for @driverPhone.
  ///
  /// In en, this message translates to:
  /// **'Driver Phone'**
  String get driverPhone;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get vehicleInfo;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @vehiclePlate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get vehiclePlate;

  /// No description provided for @assignedAgent.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedAgent;

  /// No description provided for @noAgentAssigned.
  ///
  /// In en, this message translates to:
  /// **'No agent assigned yet'**
  String get noAgentAssigned;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated Arrival'**
  String get estimatedArrival;

  /// No description provided for @exclusive.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE'**
  String get exclusive;

  /// No description provided for @grabYourVouchers.
  ///
  /// In en, this message translates to:
  /// **'Grab Your Vouchers'**
  String get grabYourVouchers;

  /// No description provided for @upTo100000Lbp.
  ///
  /// In en, this message translates to:
  /// **'Up to 100,000 LBP'**
  String get upTo100000Lbp;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get supportMessageHint;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @availableVouchers.
  ///
  /// In en, this message translates to:
  /// **'Available Vouchers'**
  String get availableVouchers;

  /// No description provided for @pastVouchers.
  ///
  /// In en, this message translates to:
  /// **'Past Vouchers'**
  String get pastVouchers;

  /// No description provided for @inviteAndWin.
  ///
  /// In en, this message translates to:
  /// **'invite & win'**
  String get inviteAndWin;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'2Friends'**
  String get friends;

  /// No description provided for @winVouchers.
  ///
  /// In en, this message translates to:
  /// **'Win 5 Vouchers'**
  String get winVouchers;

  /// No description provided for @worth210000Lbp.
  ///
  /// In en, this message translates to:
  /// **'Worth 210,000 LBP'**
  String get worth210000Lbp;

  /// No description provided for @tcApply.
  ///
  /// In en, this message translates to:
  /// **'T&C APPLY'**
  String get tcApply;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @popularBrands.
  ///
  /// In en, this message translates to:
  /// **'Popular Brands'**
  String get popularBrands;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @offersForYou.
  ///
  /// In en, this message translates to:
  /// **'Offers For You'**
  String get offersForYou;

  /// No description provided for @nearbyYou.
  ///
  /// In en, this message translates to:
  /// **'Nearby You'**
  String get nearbyYou;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @filtersActive.
  ///
  /// In en, this message translates to:
  /// **'Filters Active'**
  String get filtersActive;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @noProductsAvailableAtThisTime.
  ///
  /// In en, this message translates to:
  /// **'No Products Available At This Time'**
  String get noProductsAvailableAtThisTime;

  /// No description provided for @applyVoucher.
  ///
  /// In en, this message translates to:
  /// **'Apply Voucher'**
  String get applyVoucher;

  /// No description provided for @voucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get voucher;

  /// No description provided for @saveMore.
  ///
  /// In en, this message translates to:
  /// **'Save More'**
  String get saveMore;

  /// No description provided for @noSpecialOffers.
  ///
  /// In en, this message translates to:
  /// **'No Special Offers'**
  String get noSpecialOffers;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @selectCuisine.
  ///
  /// In en, this message translates to:
  /// **'Select Cuisine'**
  String get selectCuisine;

  /// No description provided for @allCuisines.
  ///
  /// In en, this message translates to:
  /// **'All Cuisines'**
  String get allCuisines;

  /// No description provided for @failedToLoadOffers.
  ///
  /// In en, this message translates to:
  /// **'Failed To Load Offers'**
  String get failedToLoadOffers;

  /// No description provided for @spOffersAvailable.
  ///
  /// In en, this message translates to:
  /// **'Special Offers Available'**
  String get spOffersAvailable;

  /// No description provided for @get.
  ///
  /// In en, this message translates to:
  /// **'Get'**
  String get get;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @noVouchersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Vouchers Available'**
  String get noVouchersAvailable;

  /// No description provided for @addItemsToCart.
  ///
  /// In en, this message translates to:
  /// **'Add Items to Cart'**
  String get addItemsToCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is Empty'**
  String get cartEmpty;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @creditDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get creditDebitCard;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @ordersTotals.
  ///
  /// In en, this message translates to:
  /// **'Order\'s Totals'**
  String get ordersTotals;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @pleaseSelectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Please Select Delivery Address'**
  String get pleaseSelectDeliveryAddress;

  /// No description provided for @pleaseSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Please Select Payment Method'**
  String get pleaseSelectPaymentMethod;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter A Phone Number'**
  String get phoneNumberHint;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your phone'**
  String get otpSentMessage;

  /// No description provided for @selectYourCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Your Country'**
  String get selectYourCountry;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Lebanese phone number\\n(e.g., 03 123456, 70 123456)'**
  String get invalidPhoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @enterPhoneToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter phone to reset password'**
  String get enterPhoneToResetPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8+ chars with uppercase, lowercase, number & special character'**
  String get passwordRequirements;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustContainNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number'**
  String get passwordMustContainNumber;

  /// No description provided for @passwordMustContainLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a lowercase letter'**
  String get passwordMustContainLowercase;

  /// No description provided for @passwordMainRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get passwordMainRequirements;

  /// No description provided for @passwordMustContainUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordMustContainUppercase;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @oneUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get oneUppercaseLetter;

  /// No description provided for @oneLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get oneLowercaseLetter;

  /// No description provided for @oneNumber.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get oneNumber;

  /// No description provided for @verifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully'**
  String get verifiedSuccessfully;

  /// No description provided for @notVerifiedPleaseCompleteVerification.
  ///
  /// In en, this message translates to:
  /// **'Not verified. Please complete verification.'**
  String get notVerifiedPleaseCompleteVerification;

  /// No description provided for @setPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t set a password yet. Set one now to log in next time.'**
  String get setPasswordSubtitle;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @mustCompleteVerificationBeforeSettingPassword.
  ///
  /// In en, this message translates to:
  /// **'You must complete verification before setting a password'**
  String get mustCompleteVerificationBeforeSettingPassword;

  /// No description provided for @passwordSetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password set successfully'**
  String get passwordSetSuccessfully;

  /// No description provided for @failedToSetPassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to set password'**
  String get failedToSetPassword;

  /// No description provided for @inLabel.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inLabel;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @weHaveSentACodeTo.
  ///
  /// In en, this message translates to:
  /// **'We have sent a code to'**
  String get weHaveSentACodeTo;

  /// No description provided for @failedToResendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code'**
  String get failedToResendCode;

  /// No description provided for @phoneNumberMissing.
  ///
  /// In en, this message translates to:
  /// **'Phone number missing'**
  String get phoneNumberMissing;

  /// No description provided for @youCanVerifyLaterFromProfile.
  ///
  /// In en, this message translates to:
  /// **'You can verify later from Profile'**
  String get youCanVerifyLaterFromProfile;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @verificationCodeReceived.
  ///
  /// In en, this message translates to:
  /// **'Verification code received: '**
  String get verificationCodeReceived;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @loginToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Login to unlock'**
  String get loginToUnlock;

  /// No description provided for @upTo.
  ///
  /// In en, this message translates to:
  /// **'Up to'**
  String get upTo;

  /// No description provided for @myFavourites.
  ///
  /// In en, this message translates to:
  /// **'My favourites'**
  String get myFavourites;

  /// No description provided for @passwordAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password & Security'**
  String get passwordAndSecurity;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @aboutSika.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get aboutSika;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @clearCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'This will remove all cached data and free up storage space.'**
  String get clearCacheDescription;

  /// No description provided for @cacheClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheClearedSuccessfully;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see order details once you log out.'**
  String get logoutMessage;

  /// No description provided for @ins.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get ins;

  /// No description provided for @userPhoneNumberNotFound.
  ///
  /// In en, this message translates to:
  /// **'User phone number not found'**
  String get userPhoneNumberNotFound;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to '**
  String get verificationCodeSent;

  /// No description provided for @failedToSendOTP.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOTP;

  /// No description provided for @verifyYourIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyYourIdentity;

  /// No description provided for @verifyYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyYourPhoneNumber;

  /// No description provided for @verificationCodeSentDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit verification code to your phone number. This confirms your identity before changing your password.'**
  String get verificationCodeSentDescription;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @copyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© All rights reserved.'**
  String get copyrightNotice;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @supportAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get supportAndFeedback;

  /// No description provided for @greatDeals.
  ///
  /// In en, this message translates to:
  /// **'Great deals'**
  String get greatDeals;

  /// No description provided for @exclusiveDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Exclusive discounts'**
  String get exclusiveDiscounts;

  /// No description provided for @realTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Real-time tracking'**
  String get realTimeTracking;

  /// No description provided for @trackYourOrderInRealTime.
  ///
  /// In en, this message translates to:
  /// **'Track your order in real time'**
  String get trackYourOrderInRealTime;

  /// No description provided for @multiplePaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Multiple payment options'**
  String get multiplePaymentOptions;

  /// No description provided for @topRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Top restaurants'**
  String get topRestaurants;

  /// No description provided for @browseAndOrderFromHundredsOfRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Browse and order from hundreds of restaurants'**
  String get browseAndOrderFromHundredsOfRestaurants;

  /// No description provided for @fastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery'**
  String get fastDelivery;

  /// No description provided for @getYourFoodDeliveredIn30To45Minutes.
  ///
  /// In en, this message translates to:
  /// **'Get your food delivered in 30 to 45 minutes'**
  String get getYourFoodDeliveredIn30To45Minutes;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key features'**
  String get keyFeatures;

  /// No description provided for @yearsServing.
  ///
  /// In en, this message translates to:
  /// **'Years serving'**
  String get yearsServing;

  /// No description provided for @aboutUsDescription.
  ///
  /// In en, this message translates to:
  /// **'We connect you to hundreds of restaurants for a fast, secure and convenient food ordering experience.'**
  String get aboutUsDescription;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @yourFavoriteFoodDeliveryApp.
  ///
  /// In en, this message translates to:
  /// **'Your favorite food delivery app'**
  String get yourFavoriteFoodDeliveryApp;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setAsDefaultAddress;

  /// No description provided for @editDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit delivery address'**
  String get editDeliveryAddress;

  /// No description provided for @selectAddressType.
  ///
  /// In en, this message translates to:
  /// **'Select address type'**
  String get selectAddressType;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @buildingNameStreet.
  ///
  /// In en, this message translates to:
  /// **'Building name / Street'**
  String get buildingNameStreet;

  /// No description provided for @apartmentNumber.
  ///
  /// In en, this message translates to:
  /// **'Apartment number'**
  String get apartmentNumber;

  /// No description provided for @unitFloor.
  ///
  /// In en, this message translates to:
  /// **'Unit / Floor'**
  String get unitFloor;

  /// No description provided for @contactPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact phone number'**
  String get contactPhoneNumber;

  /// No description provided for @contactPhoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Contact phone number (optional)'**
  String get contactPhoneNumberOptional;

  /// No description provided for @pleaseEnterAnAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an address'**
  String get pleaseEnterAnAddress;

  /// No description provided for @thisAddressAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This address already exists'**
  String get thisAddressAlreadyExists;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @errorChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error changing password'**
  String get errorChangingPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPassword;

  /// No description provided for @createAStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createAStrongPassword;

  /// No description provided for @passwordSentenceRequirements.
  ///
  /// In en, this message translates to:
  /// **'Make sure it\'s at least 8 characters long and includes a mix of letters, numbers, and symbols.'**
  String get passwordSentenceRequirements;

  /// No description provided for @passwordMustContain.
  ///
  /// In en, this message translates to:
  /// **'Password must contain'**
  String get passwordMustContain;

  /// No description provided for @changing.
  ///
  /// In en, this message translates to:
  /// **'Changing...'**
  String get changing;

  /// No description provided for @emailUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully'**
  String get emailUpdatedSuccessfully;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @securityWarning.
  ///
  /// In en, this message translates to:
  /// **'To ensure the security of your account, please log in again after changing email address.'**
  String get securityWarning;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// No description provided for @phoneNumberCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed'**
  String get phoneNumberCannotBeChanged;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @usernameUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Username updated successfully'**
  String get usernameUpdatedSuccessfully;

  /// No description provided for @failedToUpdateUsername.
  ///
  /// In en, this message translates to:
  /// **'Failed to update username'**
  String get failedToUpdateUsername;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @pleaseEnterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterYourFirstName;

  /// No description provided for @favoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'Favorite Products'**
  String get favoriteProducts;

  /// No description provided for @removed_from_favorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removed_from_favorites;

  /// No description provided for @favoriteStores.
  ///
  /// In en, this message translates to:
  /// **'Favorite Stores'**
  String get favoriteStores;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @startAddingYourFavoriteRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Start adding your favorite restaurants'**
  String get startAddingYourFavoriteRestaurants;

  /// No description provided for @locationPermissionsPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions permanently denied'**
  String get locationPermissionsPermanentlyDenied;

  /// No description provided for @errorGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get errorGettingLocation;

  /// No description provided for @moveMapHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map to adjust the pin'**
  String get moveMapHint;

  /// No description provided for @courierDeliveryNote.
  ///
  /// In en, this message translates to:
  /// **'Courier delivery note'**
  String get courierDeliveryNote;

  /// No description provided for @locateMe.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get locateMe;

  /// No description provided for @failedToSavePreference.
  ///
  /// In en, this message translates to:
  /// **'Failed to save preference'**
  String get failedToSavePreference;

  /// No description provided for @receivePushNotification.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get receivePushNotification;

  /// No description provided for @getLatestOffersViaText.
  ///
  /// In en, this message translates to:
  /// **'Get the latest offers via text'**
  String get getLatestOffersViaText;

  /// No description provided for @passwordManagement.
  ///
  /// In en, this message translates to:
  /// **'Password Management'**
  String get passwordManagement;

  /// No description provided for @passwordManagementInfo.
  ///
  /// In en, this message translates to:
  /// **'You need a password for your security. Every 72 hours you\'ll be asked to verify it.'**
  String get passwordManagementInfo;

  /// No description provided for @setYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Set your password'**
  String get setYourPassword;

  /// No description provided for @createAStrongPasswordForYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password for your account'**
  String get createAStrongPasswordForYourAccount;

  /// No description provided for @changeYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get changeYourPassword;

  /// No description provided for @updateYourExistingPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your existing password'**
  String get updateYourExistingPassword;

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security Tips'**
  String get securityTips;

  /// No description provided for @useAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get useAtLeast8Characters;

  /// No description provided for @longerPasswordsAreMoreSecure.
  ///
  /// In en, this message translates to:
  /// **'Longer passwords are more secure'**
  String get longerPasswordsAreMoreSecure;

  /// No description provided for @mixLettersNumbersAndSymbols.
  ///
  /// In en, this message translates to:
  /// **'Mix letters, numbers, and symbols'**
  String get mixLettersNumbersAndSymbols;

  /// No description provided for @avoidUsingPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Avoid using personal information'**
  String get avoidUsingPersonalInformation;

  /// No description provided for @dontReuseOldPasswords.
  ///
  /// In en, this message translates to:
  /// **'Don\'t reuse old passwords'**
  String get dontReuseOldPasswords;

  /// No description provided for @eachPasswordShouldBeUnique.
  ///
  /// In en, this message translates to:
  /// **'Each password should be unique'**
  String get eachPasswordShouldBeUnique;

  /// No description provided for @neverShareYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Never share your password'**
  String get neverShareYourPassword;

  /// No description provided for @weWillNeverAskForYourPassword.
  ///
  /// In en, this message translates to:
  /// **'We will never ask for your password'**
  String get weWillNeverAskForYourPassword;

  /// No description provided for @errorLoadingPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Error loading payment methods'**
  String get errorLoadingPaymentMethods;

  /// No description provided for @noSavedCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved cards yet'**
  String get noSavedCardsYet;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @areYouSureYouWantToRemoveThisCard.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this card?'**
  String get areYouSureYouWantToRemoveThisCard;

  /// No description provided for @pleaseEnterBankCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter bank card number'**
  String get pleaseEnterBankCardNumber;

  /// No description provided for @pleaseEnterCardholderName.
  ///
  /// In en, this message translates to:
  /// **'Please enter cardholder name'**
  String get pleaseEnterCardholderName;

  /// No description provided for @sikaProtectsYourCardInformation.
  ///
  /// In en, this message translates to:
  /// **'Sika protects your card information'**
  String get sikaProtectsYourCardInformation;

  /// No description provided for @sikaAdheresToPciDss.
  ///
  /// In en, this message translates to:
  /// **'Sika adheres to PCI DSS'**
  String get sikaAdheresToPciDss;

  /// No description provided for @cardInformationIsKeptSecure.
  ///
  /// In en, this message translates to:
  /// **'Card information is kept secure'**
  String get cardInformationIsKeptSecure;

  /// No description provided for @allDataIsEncrypted.
  ///
  /// In en, this message translates to:
  /// **'All data is encrypted'**
  String get allDataIsEncrypted;

  /// No description provided for @sikaWillNeverSellYourCardInformation.
  ///
  /// In en, this message translates to:
  /// **'Sika will never sell your card information'**
  String get sikaWillNeverSellYourCardInformation;

  /// No description provided for @ifAPreAuthorisationChargeOccursTheFundsWillBeRefundedImmediately.
  ///
  /// In en, this message translates to:
  /// **'If a pre-authorisation charge occurs, the funds will be refunded immediately'**
  String get ifAPreAuthorisationChargeOccursTheFundsWillBeRefundedImmediately;

  /// No description provided for @pleaseFillInAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillInAllFields;

  /// No description provided for @pleaseEnterAValidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid card number'**
  String get pleaseEnterAValidCardNumber;

  /// No description provided for @expiryDateMustBeInMMYYFormat.
  ///
  /// In en, this message translates to:
  /// **'Expiry date must be in MM/YY format'**
  String get expiryDateMustBeInMMYYFormat;

  /// No description provided for @cvvMustBe3To4Digits.
  ///
  /// In en, this message translates to:
  /// **'CVV must be 3 to 4 digits'**
  String get cvvMustBe3To4Digits;

  /// No description provided for @cardholderNameMustContainOnlyLettersAndSpaces.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name must contain only letters and spaces'**
  String get cardholderNameMustContainOnlyLettersAndSpaces;

  /// No description provided for @failedToAddCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to add card'**
  String get failedToAddCard;

  /// No description provided for @sikaUser.
  ///
  /// In en, this message translates to:
  /// **'Sika user'**
  String get sikaUser;

  /// No description provided for @standardMessageRatesApply.
  ///
  /// In en, this message translates to:
  /// **'Standard message rates apply'**
  String get standardMessageRatesApply;

  /// No description provided for @pleaseEnterAPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a promo code'**
  String get pleaseEnterAPromoCode;

  /// No description provided for @promoCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied'**
  String get promoCodeApplied;

  /// No description provided for @errorValidatingCode.
  ///
  /// In en, this message translates to:
  /// **'Error validating code'**
  String get errorValidatingCode;

  /// No description provided for @vouchers.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get vouchers;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @inviteFriendsAndWinVouchers.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and win vouchers'**
  String get inviteFriendsAndWinVouchers;

  /// No description provided for @unableToShare.
  ///
  /// In en, this message translates to:
  /// **'Unable to share'**
  String get unableToShare;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// No description provided for @useCode.
  ///
  /// In en, this message translates to:
  /// **'Use code'**
  String get useCode;

  /// No description provided for @noPastVouchers.
  ///
  /// In en, this message translates to:
  /// **'No past vouchers'**
  String get noPastVouchers;

  /// No description provided for @noAvailableVouchers.
  ///
  /// In en, this message translates to:
  /// **'No available vouchers'**
  String get noAvailableVouchers;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @yourPoints.
  ///
  /// In en, this message translates to:
  /// **'Your points'**
  String get yourPoints;

  /// No description provided for @spendPointsToGetFreeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Spend points to get free delivery'**
  String get spendPointsToGetFreeDelivery;

  /// No description provided for @pointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Points history'**
  String get pointsHistory;

  /// No description provided for @errorGettingAddress.
  ///
  /// In en, this message translates to:
  /// **'Error getting address'**
  String get errorGettingAddress;

  /// No description provided for @receiveSmsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive SMS notifications'**
  String get receiveSmsNotifications;

  /// No description provided for @receivePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get receivePushNotifications;

  /// No description provided for @subscribeToNewsletters.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to newsletters'**
  String get subscribeToNewsletters;

  /// No description provided for @receiveLatestOffersByEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive the latest offers by email'**
  String get receiveLatestOffersByEmail;

  /// No description provided for @getTheAppToRedeem.
  ///
  /// In en, this message translates to:
  /// **'Get the app to redeem'**
  String get getTheAppToRedeem;

  /// No description provided for @saveUpTo.
  ///
  /// In en, this message translates to:
  /// **'Save up to'**
  String get saveUpTo;

  /// No description provided for @mixOfUppercaseAndLowercase.
  ///
  /// In en, this message translates to:
  /// **'Mix of uppercase and lowercase'**
  String get mixOfUppercaseAndLowercase;

  /// No description provided for @atLeastOneNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get atLeastOneNumber;

  /// No description provided for @atLeastOneSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get atLeastOneSpecialCharacter;

  /// No description provided for @createAStrongPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Make sure your password is at least 8 characters and includes uppercase and lowercase letters, numbers, and special characters.'**
  String get createAStrongPasswordDescription;

  /// No description provided for @failedToLoadBrands.
  ///
  /// In en, this message translates to:
  /// **'Failed to load brands'**
  String get failedToLoadBrands;

  /// No description provided for @noBrandsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No brands available'**
  String get noBrandsAvailable;

  /// No description provided for @noStoresAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stores available'**
  String get noStoresAvailable;

  /// No description provided for @noStoresMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No stores match the selected filters'**
  String get noStoresMatchFilters;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular searches'**
  String get popularSearches;

  /// No description provided for @friedChicken.
  ///
  /// In en, this message translates to:
  /// **'Fried Chicken'**
  String get friedChicken;

  /// No description provided for @pizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get pizza;

  /// No description provided for @salads.
  ///
  /// In en, this message translates to:
  /// **'Salads'**
  String get salads;

  /// No description provided for @cakes.
  ///
  /// In en, this message translates to:
  /// **'Cakes'**
  String get cakes;

  /// No description provided for @grill.
  ///
  /// In en, this message translates to:
  /// **'Grill'**
  String get grill;

  /// No description provided for @indian.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get indian;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// No description provided for @min30.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get min30;

  /// No description provided for @burgers.
  ///
  /// In en, this message translates to:
  /// **'Burgers'**
  String get burgers;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @errorRequestingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Error requesting permissions'**
  String get errorRequestingPermissions;

  /// No description provided for @welcomeToSika.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sika'**
  String get welcomeToSika;

  /// No description provided for @byContinuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Conditions'**
  String get byContinuing;

  /// No description provided for @locationAccessDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Location access is used to show nearby stores and delivery options.'**
  String get locationAccessDisclaimer;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @productInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Product information not available'**
  String get productInformationNotAvailable;

  /// No description provided for @categoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryNotFound;

  /// No description provided for @categoryInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Category information not available'**
  String get categoryInformationNotAvailable;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @storeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Store not found'**
  String get storeNotFound;

  /// No description provided for @storeInformationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Store information not available'**
  String get storeInformationNotAvailable;

  /// No description provided for @pleaseVerifyYourAccountToPlaceOrders.
  ///
  /// In en, this message translates to:
  /// **'Please verify your account to place orders'**
  String get pleaseVerifyYourAccountToPlaceOrders;

  /// No description provided for @errorVerifyingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error verifying password'**
  String get errorVerifyingPassword;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @newUserEvouchers.
  ///
  /// In en, this message translates to:
  /// **'New user e-vouchers'**
  String get newUserEvouchers;

  /// No description provided for @failedToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh'**
  String get failedToRefresh;

  /// No description provided for @sortedBy.
  ///
  /// In en, this message translates to:
  /// **'Sorted by'**
  String get sortedBy;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied permanently'**
  String get locationPermissionDeniedForever;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderedItems.
  ///
  /// In en, this message translates to:
  /// **'Ordered items'**
  String get orderedItems;

  /// No description provided for @twoItems.
  ///
  /// In en, this message translates to:
  /// **'2 items'**
  String get twoItems;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select a location'**
  String get pleaseSelectLocation;

  /// No description provided for @whatsappNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed on this device'**
  String get whatsappNotInstalled;

  /// No description provided for @unableToLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Unable to load transactions'**
  String get unableToLoadTransactions;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get topRated;

  /// No description provided for @fastestDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fastest delivery'**
  String get fastestDelivery;

  /// No description provided for @clearSort.
  ///
  /// In en, this message translates to:
  /// **'Clear sort'**
  String get clearSort;

  /// No description provided for @lowestDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Lowest delivery fee'**
  String get lowestDeliveryFee;

  /// No description provided for @signupOrLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign up or Login'**
  String get signupOrLogin;

  /// No description provided for @newUserWelcomeVouchers.
  ///
  /// In en, this message translates to:
  /// **'New user welcome vouchers'**
  String get newUserWelcomeVouchers;

  /// No description provided for @youNeedToVerifyYourAccountBeforeYouCanAddItemsToCartOrPlaceOrders.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your account before you can add items to cart or place orders'**
  String get youNeedToVerifyYourAccountBeforeYouCanAddItemsToCartOrPlaceOrders;

  /// No description provided for @registerForMore.
  ///
  /// In en, this message translates to:
  /// **'Register to see more stores'**
  String get registerForMore;

  /// No description provided for @labelNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get labelNew;

  /// No description provided for @butler.
  ///
  /// In en, this message translates to:
  /// **'Butler'**
  String get butler;

  /// No description provided for @startSearching.
  ///
  /// In en, this message translates to:
  /// **'Start Searching'**
  String get startSearching;

  /// No description provided for @weDeliverEverything.
  ///
  /// In en, this message translates to:
  /// **'We Deliver Everything'**
  String get weDeliverEverything;

  /// No description provided for @orderInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'You can\'t log out or delete account while order is happening'**
  String get orderInProgressMessage;

  /// No description provided for @paymentInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'You can\'t log out or delete account while payment is happening'**
  String get paymentInProgressMessage;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Get help using keyword'**
  String get faqSearchHint;

  /// No description provided for @faqNoResults.
  ///
  /// In en, this message translates to:
  /// **'No FAQ entries match your search.'**
  String get faqNoResults;

  /// No description provided for @faqPoliciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get faqPoliciesTitle;

  /// No description provided for @faqGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get faqGeneralTitle;

  /// No description provided for @faqOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get faqOrdersTitle;

  /// No description provided for @faqCancellationRefundPolicy.
  ///
  /// In en, this message translates to:
  /// **'What is your cancellation and refund policy?'**
  String get faqCancellationRefundPolicy;

  /// No description provided for @faqBecomeShopper.
  ///
  /// In en, this message translates to:
  /// **'How do I become a Shopper with Sika?'**
  String get faqBecomeShopper;

  /// No description provided for @faqJoinPartnerStore.
  ///
  /// In en, this message translates to:
  /// **'How can I join Sika as a partner store?'**
  String get faqJoinPartnerStore;

  /// No description provided for @faqDataUsage.
  ///
  /// In en, this message translates to:
  /// **'How do you use my data?'**
  String get faqDataUsage;

  /// No description provided for @faqTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'What are your Terms and Conditions?'**
  String get faqTermsConditions;

  /// No description provided for @faqWhenAvailable.
  ///
  /// In en, this message translates to:
  /// **'When is Sika available?'**
  String get faqWhenAvailable;

  /// No description provided for @faqWhatIsSika.
  ///
  /// In en, this message translates to:
  /// **'What is Sika?'**
  String get faqWhatIsSika;

  /// No description provided for @faqProductsDeliver.
  ///
  /// In en, this message translates to:
  /// **'What products does Sika deliver?'**
  String get faqProductsDeliver;

  /// No description provided for @faqWhereAvailable.
  ///
  /// In en, this message translates to:
  /// **'Where is Sika available?'**
  String get faqWhereAvailable;

  /// No description provided for @faqDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'How long will my delivery take?'**
  String get faqDeliveryTime;

  /// No description provided for @faqEditCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Can I edit or cancel an order?'**
  String get faqEditCancelOrder;

  /// No description provided for @faqPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'What payment methods do you accept?'**
  String get faqPaymentMethods;

  /// No description provided for @faqTrackDriver.
  ///
  /// In en, this message translates to:
  /// **'How do I track my driver?'**
  String get faqTrackDriver;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
