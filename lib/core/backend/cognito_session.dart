import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

/// Turns true the moment Cognito is seen rejecting the session, from
/// [readCognitoSession] or from Amplify's own `sessionExpired` Hub event.
/// The app listens to it to send the member to Login with an explanation.
/// Reset on the next sign-in.
final ValueNotifier<bool> cognitoSessionExpired = ValueNotifier(false);

enum CognitoSessionState {
  /// Signed in with usable tokens (or tokens that only failed to refresh
  /// because the phone is offline).
  active,

  /// Cognito rejected the refresh: the 30-day refresh token expired, or the
  /// user was deleted, disabled or signed out elsewhere. Amplify has already
  /// dropped the tokens; only a new sign-in brings the session back.
  expired,

  /// Nobody signed in on this phone.
  signedOut,
}

/// Reads the real state of the Cognito session.
///
/// `isSignedIn` alone is not enough: on the call where the refresh token is
/// rejected, Amplify still answers `isSignedIn: true` and reports the
/// failure only in `userPoolTokensResult`.
Future<CognitoSessionState> readCognitoSession() async {
  if (!Amplify.isConfigured) return CognitoSessionState.signedOut;
  try {
    final session = await Amplify.Auth.fetchAuthSession();
    if (!session.isSignedIn) return CognitoSessionState.signedOut;
    if (session is CognitoAuthSession) {
      final tokens = session.userPoolTokensResult;
      // Only an expired session counts. A network error while refreshing
      // keeps the member signed in, so the app still works offline.
      if (tokens.exception is SessionExpiredException) {
        cognitoSessionExpired.value = true;
        return CognitoSessionState.expired;
      }
    }
    return CognitoSessionState.active;
  } on SessionExpiredException {
    cognitoSessionExpired.value = true;
    return CognitoSessionState.expired;
  } on AuthException {
    return CognitoSessionState.signedOut;
  }
}
