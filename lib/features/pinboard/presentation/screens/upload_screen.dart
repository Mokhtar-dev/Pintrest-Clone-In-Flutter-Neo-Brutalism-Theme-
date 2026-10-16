import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/pin_service.dart';
import '../../../../services/user_service.dart';
import '../widgets/neo_feedback.dart';

class UploadScreen extends StatefulWidget {
  /// Image selected on the previous step (AddImageScreen).
  final XFile? initialImage;

  const UploadScreen({super.key, this.initialImage});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  bool _isButtonPressed = false;
  bool _publishing = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _loadBytes(widget.initialImage!);
    }
  }

  Future<void> _loadBytes(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (_) {
      if (mounted) showNeoTip(context, 'MEDIA READ FAULT // RESELECT ASSET');
    }
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (image == null) return;
    await _loadBytes(image);
  }

  Future<double> _decodeAspectRatio(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final ratio = image.height == 0 ? 0.75 : image.width / image.height;
      image.dispose();
      codec.dispose();
      return ratio;
    } catch (_) {
      return 0.75;
    }
  }

  Future<void> _publish() async {
    if (_imageBytes == null) {
      showNeoTip(context, 'SELECT A MEDIA ASSET FIRST');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      showNeoTip(context, 'PIN TITLE REQUIRED');
      return;
    }

    setState(() => _publishing = true);
    try {
      final uid = AuthService.instance.currentUid;
      final me = await UserService.instance.getUser(uid);
      if (me == null) {
        if (mounted) showNeoTip(context, 'PROFILE LINK LOST // RE-AUTHENTICATE');
        return;
      }
      final aspectRatio = await _decodeAspectRatio(_imageBytes!);

      await PinService.instance.createPin(
        bytes: _imageBytes!,
        title: _titleController.text,
        description: '',
        aspectRatio: aspectRatio,
        author: me,
      );

      if (!mounted) return;
      showNeoTip(context, 'DROP PUBLISHED // LIVE ON THE GRID');
      // Back to the feed.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) showNeoTip(context, 'UPLOAD FAULT // CHECK CONNECTION');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF350), // Vibrant neo-brutalist yellow backdrop
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'NEW PIN // UPLOAD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field Label
              const Text(
                'PIN TITLE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Title Input Container with Hard Shadow
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'What is this pin about?',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Image Section Label
              const Text(
                'MEDIA ASSET',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Image Picker / Preview Box
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4081), // Hot pink pop accent
                                border: Border.all(color: Colors.black, width: 3),
                              ),
                              child: const Icon(
                                Icons.add_a_photo_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'CLICK TO CHOOSE FROM GALLERY',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  'CHANGE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),

              // Tactile Press Button Component
              GestureDetector(
                onTapDown: _publishing
                    ? null
                    : (_) => setState(() => _isButtonPressed = true),
                onTapUp: _publishing
                    ? null
                    : (_) {
                        setState(() => _isButtonPressed = false);
                        _publish();
                      },
                onTapCancel: () {
                  if (!_publishing) {
                    setState(() => _isButtonPressed = false);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: Matrix4.translationValues(
                    _isButtonPressed ? 4.0 : 0.0,
                    _isButtonPressed ? 4.0 : 0.0,
                    0.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF), // Electric cyan accent
                    border: Border.all(color: Colors.black, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: _isButtonPressed
                            ? const Offset(1, 1)
                            : const Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: _publishing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'PUBLISH PIN 🚀',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
