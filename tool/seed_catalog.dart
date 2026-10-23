// Seeds the Amplify catalog tables (Crystal, Question, QuestionOption) from
// the app's own definitions, so backend ids always match the ids the app
// already uses in `discoveryQuiz` and `Crystal`.
//
// Usage:
//   dart run tool/seed_catalog.dart [--profile hikaru-amplify-admin]
//       [--region us-east-1] [--dry-run]
//
// Requires the AWS CLI with a profile that can write to DynamoDB. The table
// suffix is discovered from the `Crystal-*` table in the region.

import 'dart:convert';
import 'dart:io';

import 'package:hikaru/features/crystals/domain/crystal.dart';
import 'package:hikaru/features/crystals/domain/crystal_code.dart';
import 'package:hikaru/features/listening_room/domain/discovery_quiz.dart';

const _defaultProfile = 'hikaru-amplify-admin';
const _defaultRegion = 'us-east-1';
const _batchLimit = 25;

Future<void> main(List<String> args) async {
  final profile = _argValue(args, '--profile') ?? _defaultProfile;
  final region = _argValue(args, '--region') ?? _defaultRegion;
  final dryRun = args.contains('--dry-run');

  final suffix = await _tableSuffix(profile: profile, region: region);
  final now = DateTime.now().toUtc().toIso8601String();

  final requests = <String, List<Map<String, Object?>>>{
    'Crystal-$suffix': [
      for (final crystal in Crystal.values) _crystalItem(crystal, now),
    ],
    'Question-$suffix': [
      for (final question in discoveryQuiz) _questionItem(question, now),
    ],
    'QuestionOption-$suffix': [
      for (final question in discoveryQuiz)
        for (final (index, option) in question.options.indexed)
          _optionItem(question, option, index + 1, now),
    ],
  };

  for (final entry in requests.entries) {
    stdout.writeln('${entry.key}: ${entry.value.length} items');
  }
  if (dryRun) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(requests));
    return;
  }

  final tempDir = await Directory.systemTemp.createTemp('hikaru_seed_');
  try {
    var batch = 0;
    for (final entry in requests.entries) {
      final items = entry.value;
      for (var start = 0; start < items.length; start += _batchLimit) {
        final slice = items.sublist(
          start,
          start + _batchLimit > items.length
              ? items.length
              : start + _batchLimit,
        );
        final file = File('${tempDir.path}/batch_${batch++}.json');
        await file.writeAsString(
          jsonEncode({
            entry.key: [
              for (final item in slice)
                {
                  'PutRequest': {'Item': item},
                },
            ],
          }),
        );
        await _batchWrite(file, profile: profile, region: region);
      }
    }
  } finally {
    await tempDir.delete(recursive: true);
  }
  stdout.writeln('Catalog seeded.');
}

Map<String, Object?> _crystalItem(Crystal crystal, String now) => {
  'code': _s(crystal.backendCode),
  'name': _s(crystal.catalogName),
  'templeName': _s(crystal.temple),
  'frequencyHz': {'N': '${crystal.hertz}'},
  'primaryPurpose': _s(crystal.purpose),
  'meridians': {
    'L': [for (final meridian in crystal.meridianList) _s(meridian)],
  },
  ..._meta('Crystal', now),
};

Map<String, Object?> _questionItem(DiscoveryQuestion question, String now) => {
  'id': _s(quizQuestionBackendId(question.number)),
  'text': _s(question.prompt),
  'sortOrder': {'N': '${question.number}'},
  ..._meta('Question', now),
};

Map<String, Object?> _optionItem(
  DiscoveryQuestion question,
  QuizOption option,
  int sortOrder,
  String now,
) => {
  'id': _s(option.id),
  'text': _s(option.label),
  'sortOrder': {'N': '$sortOrder'},
  'questionId': _s(quizQuestionBackendId(question.number)),
  ..._meta('QuestionOption', now),
};

Map<String, Object?> _meta(String typeName, String now) => {
  '__typename': _s(typeName),
  'createdAt': _s(now),
  'updatedAt': _s(now),
};

Map<String, String> _s(String value) => {'S': value};

String? _argValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}

Future<String> _tableSuffix({
  required String profile,
  required String region,
}) async {
  final result = await _aws([
    'dynamodb',
    'list-tables',
    '--profile',
    profile,
    '--region',
    region,
    '--output',
    'json',
  ]);
  final decoded = jsonDecode(result) as Map<String, dynamic>;
  final names = (decoded['TableNames'] as List).cast<String>();
  final crystalTable = names
      .where((name) => name.startsWith('Crystal-'))
      .toList();
  if (crystalTable.length != 1) {
    throw StateError('Expected one Crystal table, found $crystalTable');
  }
  return crystalTable.single.substring('Crystal-'.length);
}

Future<void> _batchWrite(
  File file, {
  required String profile,
  required String region,
}) async {
  var pending = file;
  for (var attempt = 0; attempt < 5; attempt++) {
    final output = await _aws([
      'dynamodb',
      'batch-write-item',
      '--request-items',
      'file://${pending.path}',
      '--profile',
      profile,
      '--region',
      region,
      '--output',
      'json',
    ]);
    final decoded = jsonDecode(output) as Map<String, dynamic>;
    final unprocessed = decoded['UnprocessedItems'] as Map<String, dynamic>?;
    if (unprocessed == null || unprocessed.isEmpty) return;
    pending = File('${file.path}.retry$attempt')
      ..writeAsStringSync(jsonEncode(unprocessed));
    await Future<void>.delayed(Duration(seconds: 1 << attempt));
  }
  throw StateError('DynamoDB left items unprocessed after retries.');
}

Future<String> _aws(List<String> arguments) async {
  final result = await Process.run('aws', arguments, runInShell: true);
  if (result.exitCode != 0) {
    throw ProcessException(
      'aws',
      arguments,
      '${result.stderr}',
      result.exitCode,
    );
  }
  return '${result.stdout}';
}
