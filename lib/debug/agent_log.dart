/// Debug agent logging utility
/// Used by org_switcher for development diagnostics.
/// No-op in release builds.
void agentLog({
  String? hypothesisId,
  String? location,
  String? message,
  Map<String, dynamic>? data,
}) {
  // Agent logging is a development-only diagnostic tool.
  // In production, this is compiled away by Dart tree-shaking
  // since the calls are only in debug assertions.
  assert(() {
    // ignore: avoid_print
    print('[AgentLog] $hypothesisId | $location | $message $data');
    return true;
  }());
}
