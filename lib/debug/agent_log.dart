import 'dart:async';
import 'dart:convert';
import 'dart:io';

// #region agent log
void agentLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'pre-fix',
}) {
  try {
    final payload = <String, Object?>{
      'sessionId': 'bea2bf',
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    // Prefer shipping logs to the host-side ingest server (via adb reverse),
    // because local filesystem writes on mobile won't land in the workspace.
    if (Platform.isAndroid || Platform.isIOS) {
      unawaited(() async {
        try {
          final req = await HttpClient().postUrl(Uri.parse(
              'http://127.0.0.1:7368/ingest/5062ab2d-1061-4402-8e74-e674f10a4efa'));
          req.headers.contentType = ContentType.json;
          req.headers.set('X-Debug-Session-Id', 'bea2bf');
          req.write(jsonEncode(payload));
          await req.close();
        } catch (_) {}
      }());
      return;
    }

    // Desktop / tests: write directly in the workspace.
    File('debug-bea2bf.log')
        .writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
  } catch (_) {
    // Intentionally swallow logging failures.
  }
}
// #endregion

