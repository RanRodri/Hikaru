import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'merkaba_progress_repository.g.dart';

/// Records finished Merkaba sessions. The backend implementation replaces
/// [InMemoryMerkabaProgressRepository] once the API exists.
abstract interface class MerkabaProgressRepository {
  Future<void> recordCompletion(DateTime completedAt);

  Future<List<DateTime>> completions();
}

class InMemoryMerkabaProgressRepository implements MerkabaProgressRepository {
  final List<DateTime> _completions = [];

  @override
  Future<void> recordCompletion(DateTime completedAt) async {
    _completions.add(completedAt);
  }

  @override
  Future<List<DateTime>> completions() async => List.unmodifiable(_completions);
}

@Riverpod(keepAlive: true)
MerkabaProgressRepository merkabaProgressRepository(Ref ref) =>
    InMemoryMerkabaProgressRepository();
