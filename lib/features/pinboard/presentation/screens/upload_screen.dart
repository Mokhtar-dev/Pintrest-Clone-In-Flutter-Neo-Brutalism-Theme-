import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/utils/link_probe.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/pin_service.dart';
import '../../../../services/user_service.dart';
import '../widgets/neo_feedback.dart';

/// URL-based upload ("URL UPLINK") screen.
///
/// The operator pastes a direct image link (ending in .jpg/.png/.webp, or a
/// raw image address from Unsplash/Imgur), sees a live preview, and publishes
/// straight to Firestore. No Firebase Storage is required, so the app runs
/// fully on the free Firebase plan.
///
/// Before publishing, the link is probed (HTTP headers only): web-page links
/// (text/html), blocked links (403) and broken links (404) are rejected with
/// a precise reason so the grid never receives a dead image.
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  Timer? _previewDebounce;
  bool _isLoading = false;
  String? _imageUrlPreview;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  /// Debounced so the preview does not fire a request for every keystroke
  /// (partial URLs would fail and flash the error state while typing).
  void _onUrlChanged() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        final url = _normalizeImageUrl(_urlController.text);
        _imageUrlPreview = url.isEmpty ? null : url;
      });
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// Trims the paste and prepends `https://` when a bare `host/path` link is
  /// copied without its scheme.
  String _normalizeImageUrl(String raw) {
    final url = raw.trim();
    if (url.isEmpty) return '';
    if (!url.contains('://')) return 'https://$url';
    return url;
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _publishPin() async {
    final title = _titleController.text.trim();
    final imageUrl = _normalizeImageUrl(_urlController.text);

    if (title.isEmpty || imageUrl.isEmpty) {
      showNeoError(context, 'ERROR // TITLE AND IMAGE URL REQUIRED');
      return;
    }
    if (!_isValidUrl(imageUrl)) {
      showNeoError(context, 'ERROR // URL MUST START WITH HTTP(S)://');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (AuthService.instance.currentUid.isEmpty) {
        if (mounted) showNeoError(context, 'SESSION LOST // LOG IN AGAIN');
        return;
      }
      final me = await UserService.instance.ensureUserProfile();
      if (me == null) {
        if (mounted) {
          showNeoError(context, 'PUBLISH FAILED: NO OPERATOR FOUND');
        }
        return;
      }

      // Verify the link actually serves an image before writing to Firestore,
      // so the grid never receives page links or dead images.
      final probe = await probeImageLink(imageUrl);
      if (probe.supported) {
        final host = Uri.parse(imageUrl).host;
        if (probe.status == 0) {
          if (mounted) {
            showNeoError(context, 'NETWORK ERROR // CANNOT REACH $host');
          }
          return;
        }
        if (probe.mime.contains('text/html')) {
          if (mounted) {
            showNeoError(
              context,
              'THAT IS A WEB PAGE, NOT AN IMAGE // OPEN THE IMAGE, THEN COPY ITS ADDRESS',
            );
          }
          return;
        }
        if (probe.status >= 400) {
          if (mounted) {
            showNeoError(context, 'LINK BLOCKED BY HOST // CODE ${probe.status}');
          }
          return;
        }
        if (!probe.mime.startsWith('image/') &&
            !probe.mime.contains('octet-stream')) {
          if (mounted) {
            showNeoError(
              context,
              'LINK IS NOT AN IMAGE (${probe.mime.isEmpty ? 'UNKNOWN' : probe.mime.toUpperCase()})',
            );
          }
          return;
        }
      }

      // Direct Firestore write - imageUrl points to the pasted link.
      await PinService.instance.createPin(
        imageUrl: imageUrl,
        title: title,
        description: '',
        aspectRatio: 1.2, // Default standard card ratio
        author: me,
        category: 'CYBER',
        categoryLabel: 'CYBERPUNK // DROP',
        tags: const ['neo-brutalism', 'archive', 'drop'],
        badge: 'LIVE DROP',
      );

      if (!mounted) return;
      showNeoTip(context, 'DROP PUBLISHED // LIVE ON THE GRID');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) showNeoError(context, 'PUBLISH FAILED: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1110),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1110),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'NEW DROP // URL UPLINK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6FF00),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: _isLoading ? null : _publishPin,
              child: _isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'PUBLISH ✓',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image URL Input Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(
                  color: const Color(0xFFB6FF00),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IMAGE SOURCE URL // HTTPS',
                    style: TextStyle(
                      color: Color(0xFFB6FF00),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _urlController,
                    autocorrect: false,
                    keyboardType: TextInputType.url,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'Paste direct image link (e.g. Unsplash, Imgur)...',
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Live Image Preview Box
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(color: Colors.white24, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imageUrlPreview != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        _imageUrlPreview!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SIGNAL LOST // IMAGE NOT LOADED',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFFF0055),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'TIP: OPEN THE IMAGE IN THE BROWSER, THEN '
                                'LONG-PRESS / RIGHT-CLICK IT AND COPY THE '
                                'IMAGE ADDRESS (MUST END .JPG / .PNG / .WEBP).',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFB6FF00),
                            ),
                          );
                        },
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.white24,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'PREVIEW AREA // PASTE URL ABOVE',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // 3. Drop Title Input
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(color: Colors.white24, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DROP TITLE // IDENTIFIER',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. SYSTEM MATRIX 09',
                      hintStyle: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
