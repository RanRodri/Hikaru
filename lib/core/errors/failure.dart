/// Error types exposed to the presentation layer.
///
/// Repositories map backend exceptions (e.g. Amplify `ApiException`,
/// `AuthException`) to one of these so the UI never depends on AWS types.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No hay conexión a internet.']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Tu sesión no es válida. Inicia sesión de nuevo.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
