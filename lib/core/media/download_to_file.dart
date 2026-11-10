import 'dart:io';

/// Streams [url] into [target] without holding the file in memory.
///
/// Returns the bytes written, or 0 when the server refused, the transfer was
/// short, or [shouldStop] became true. A stopped transfer leaves [target]
/// for the caller to delete.
Future<int> downloadToFile(
  Uri url,
  File target, {
  bool Function()? shouldStop,
}) async {
  bool stopped() => shouldStop?.call() ?? false;
  final client = HttpClient();
  try {
    if (stopped()) return 0;
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      return 0;
    }
    if (stopped()) {
      await response.drain<void>();
      return 0;
    }
    final sink = target.openWrite();
    var written = 0;
    var halted = false;
    try {
      await for (final chunk in response) {
        if (stopped()) {
          halted = true;
          break;
        }
        sink.add(chunk);
        written += chunk.length;
      }
    } finally {
      await sink.close();
    }
    if (halted || stopped()) return 0;
    final expected = response.contentLength;
    if (expected >= 0 && written != expected) return 0;
    return written;
  } finally {
    client.close();
  }
}
