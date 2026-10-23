import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

/// Thin wrapper over the Amplify API plugin for hand-written GraphQL.
///
/// Every call degrades to `null` when Amplify is not configured, no one is
/// signed in, or the request fails, so callers can keep serving local data.
class AmplifyGraphQL {
  const AmplifyGraphQL(this.tag);

  /// Prefix for log lines, e.g. `profile` or `cycle`.
  final String tag;

  /// Cognito `sub` of the signed-in member, `null` without a session.
  Future<String?> currentUserId() async {
    if (!Amplify.isConfigured) return null;
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) return null;
      return (await Amplify.Auth.getCurrentUser()).userId;
    } on AmplifyException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> query(
    String document,
    Map<String, dynamic> variables,
  ) => _run(document, variables, mutation: false);

  Future<Map<String, dynamic>?> mutate(
    String document,
    Map<String, dynamic> variables,
  ) => _run(document, variables, mutation: true);

  Future<Map<String, dynamic>?> _run(
    String document,
    Map<String, dynamic> variables, {
    required bool mutation,
  }) async {
    if (!Amplify.isConfigured) return null;
    final request = GraphQLRequest<String>(
      document: document,
      variables: variables,
      authorizationMode: APIAuthorizationType.userPools,
    );
    try {
      final operation = mutation
          ? Amplify.API.mutate(request: request)
          : Amplify.API.query(request: request);
      final response = await operation.response;
      if (response.hasErrors) {
        safePrint('Hikaru $tag: ${response.errors}');
      }
      final raw = response.data;
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on AmplifyException catch (error) {
      safePrint('Hikaru $tag: ${error.message}');
      return null;
    }
  }
}

/// Reads every page of a `list*` connection.
Future<List<Map<String, dynamic>>> listAllPages(
  AmplifyGraphQL api,
  String document,
  String connectionField,
  Map<String, dynamic> variables,
) async {
  final items = <Map<String, dynamic>>[];
  String? nextToken;
  do {
    final data = await api.query(document, {
      ...variables,
      'nextToken': nextToken,
    });
    final page = data?[connectionField];
    if (page is! Map) return items;
    final pageItems = page['items'];
    if (pageItems is List) {
      items.addAll(pageItems.whereType<Map<String, dynamic>>());
    }
    nextToken = page['nextToken'] as String?;
  } while (nextToken != null);
  return items;
}
