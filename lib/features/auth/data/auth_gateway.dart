import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthSignUpOutcome { signedIn, confirmationRequired }

class PendingConfirmation {
  const PendingConfirmation({required this.username, required this.password});

  final String username;
  final String password;
}

class AuthRequestException implements Exception {
  const AuthRequestException(this.message);

  final String message;
}

abstract class AuthGateway {
  Future<bool> hasSession();

  Future<void> signIn({required String username, required String password});

  Future<AuthSignUpOutcome> signUp({
    required String username,
    required String password,
    required String email,
    required String name,
    String? birthdate,
  });

  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  });

  /// Emails a reset code. [username] may be the email alias.
  Future<void> requestPasswordReset({required String username});

  Future<void> confirmPasswordReset({
    required String username,
    required String newPassword,
    required String confirmationCode,
  });
}

final authGatewayProvider = Provider<AuthGateway>(
  (ref) => AmplifyAuthGateway(),
);

class AmplifyAuthGateway implements AuthGateway {
  @override
  Future<bool> hasSession() async {
    try {
      if (!Amplify.isConfigured) return false;
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } on AuthException {
      return false;
    }
  }

  @override
  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      if (result.nextStep.signInStep == AuthSignInStep.confirmSignUp) {
        throw const AuthRequestException('confirmation-required');
      }
      if (!result.isSignedIn) {
        throw AuthRequestException(result.nextStep.signInStep.name);
      }
    } on AuthRequestException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthRequestException(error.message);
    }
  }

  @override
  Future<AuthSignUpOutcome> signUp({
    required String username,
    required String password,
    required String email,
    required String name,
    String? birthdate,
  }) async {
    try {
      final attributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: email,
        AuthUserAttributeKey.name: name,
        if (birthdate != null && birthdate.isNotEmpty)
          AuthUserAttributeKey.birthdate: birthdate,
      };
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(userAttributes: attributes),
      );
      if (result.nextStep.signUpStep == AuthSignUpStep.done) {
        try {
          await signIn(username: username, password: password);
        } on AuthRequestException catch (error) {
          if (error.message == 'confirmation-required') {
            return AuthSignUpOutcome.confirmationRequired;
          }
          rethrow;
        }
        return AuthSignUpOutcome.signedIn;
      }
      return AuthSignUpOutcome.confirmationRequired;
    } on AuthException catch (error) {
      throw AuthRequestException(error.message);
    }
  }

  @override
  Future<void> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      if (!result.isSignUpComplete) {
        throw AuthRequestException(result.nextStep.signUpStep.name);
      }
    } on AuthException catch (error) {
      throw AuthRequestException(error.message);
    }
  }

  @override
  Future<void> requestPasswordReset({required String username}) async {
    try {
      final result = await Amplify.Auth.resetPassword(
        username: username.trim(),
      );
      final step = result.nextStep.updateStep;
      if (step == AuthResetPasswordStep.done) return;
      if (step != AuthResetPasswordStep.confirmResetPasswordWithCode) {
        throw AuthRequestException(step.name);
      }
    } on AuthException catch (error) {
      throw AuthRequestException(error.message);
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmResetPassword(
        username: username.trim(),
        newPassword: newPassword,
        confirmationCode: confirmationCode.trim(),
      );
      if (!result.isPasswordReset) {
        throw AuthRequestException(result.nextStep.updateStep.name);
      }
    } on AuthException catch (error) {
      throw AuthRequestException(error.message);
    }
  }
}

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{1,128}$');

bool identityLooksValid(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.contains('@')) return _emailPattern.hasMatch(trimmed);
  return _usernamePattern.hasMatch(trimmed);
}

bool usernameIsAllowed(String username) =>
    _usernamePattern.hasMatch(username.trim());

bool passwordMeetsPolicy(String password) {
  return password.length >= 8 &&
      RegExp('[A-Z]').hasMatch(password) &&
      RegExp('[a-z]').hasMatch(password) &&
      RegExp('[0-9]').hasMatch(password) &&
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);
}
