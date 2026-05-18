import 'package:flutter/widgets.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import 'package:sika_customer/core/error/exceptions.dart';

/// Returns a localized, user-facing message for the given [Exception].
/// Call this from widget code where a [BuildContext] is available.
String localizedExceptionMessage(Exception e, BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  if (e is ValidationException) return loc.invalidInput;
  if (e is NetworkException) return loc.noInternetConnection;
  if (e is ServerException) return loc.serverError;

  // Fallbacks for other exceptions — reuse existing generic messages
  if (e is AuthenticationException) return loc.pleaseTryAgain;
  if (e is UnauthorizedException) return loc.pleaseTryAgain;
  if (e is ForbiddenException) return loc.pleaseTryAgain;
  if (e is NotFoundException) return loc.locationNotFound;
  if (e is CacheException) return loc.cacheClearedSuccessfully; // closest existing cache-related string

  return loc.somethingWentWrong;
}
