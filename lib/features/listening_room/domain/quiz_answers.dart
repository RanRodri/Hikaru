class QuizAnswers {
  const QuizAnswers([this.selections = const {}]);

  final Map<int, Set<String>> selections;

  Set<String> selectedIds(int question) => selections[question] ?? const {};

  bool isSelected(int question, String optionId) =>
      selectedIds(question).contains(optionId);

  bool hasSelection(int question) => selectedIds(question).isNotEmpty;

  QuizAnswers withSelection(int question, Set<String> optionIds) {
    final next = <int, Set<String>>{
      for (final entry in selections.entries)
        entry.key: Set.unmodifiable(entry.value),
    };
    if (optionIds.isEmpty) {
      next.remove(question);
    } else {
      next[question] = Set.unmodifiable(optionIds);
    }
    return QuizAnswers(Map.unmodifiable(next));
  }

  Map<String, List<String>> toJson() => {
    for (final entry in selections.entries)
      '${entry.key}': (entry.value.toList()..sort()),
  };

  factory QuizAnswers.fromJson(Map<String, dynamic> json) {
    final selections = <int, Set<String>>{};
    for (final entry in json.entries) {
      final question = int.tryParse(entry.key);
      final raw = entry.value;
      if (question == null || raw is! List) continue;
      final ids = raw.whereType<String>().toSet();
      if (ids.isEmpty) continue;
      selections[question] = Set.unmodifiable(ids);
    }
    return QuizAnswers(Map.unmodifiable(selections));
  }
}
