/// Result of a lightweight link inspection: only HTTP status + content type.
class LinkProbeResult {
  const LinkProbeResult({
    required this.supported,
    required this.status,
    required this.mime,
  });

  /// False on platforms where raw HTTP probing is not possible (web/CORS).
  final bool supported;

  /// HTTP status code (0 when the host could not be reached).
  final int status;

  /// Response content-type mime (empty when unreachable).
  final String mime;
}

/// Web stub: probing is skipped (CORS blocks raw requests from browsers).
Future<LinkProbeResult> probeImageLink(String url) async {
  return const LinkProbeResult(supported: false, status: 0, mime: '');
}
