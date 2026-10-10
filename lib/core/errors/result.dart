import 'failure.dart';

/// Outcome of a repository operation: either a value ([Ok]) or a
/// [Failure] ([Err]).
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
