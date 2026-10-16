import 'dart:io';

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

/// Fetches the response headers only (the body is never downloaded) to learn
/// what a pasted link actually points to: an image, an HTML page, or nothing.
Future<LinkProbeResult> probeImageLink(String url) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    );
    final response =
        await request.close().timeout(const Duration(seconds: 12));
    final status = response.statusCode;
    final mime = response.headers.contentType?.mimeType ?? '';
    // Headers are all we need - drop the connection before the body arrives.
    client.close(force: true);
    return LinkProbeResult(supported: true, status: status, mime: mime);
  } on Exception {
    return const LinkProbeResult(supported: true, status: 0, mime: '');
  } finally {
    client.close(force: true);
  }
}
