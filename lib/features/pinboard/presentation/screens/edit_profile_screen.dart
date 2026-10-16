import 'package:flutter/material.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/user_service.dart';
import '../../domain/entities/app_user.dart';
import '../widgets/neo_feedback.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  AppUser? _user;
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrlDraft;
  String _pronouns = '';
  String _bio = '';

  String get _uid => AuthService.instance.currentUid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await UserService.instance.getUser(_uid);
    if (!mounted) return;
    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _websiteController.text = user.website;
      _pronouns = user.pronouns;
      _bio = user.bio;
    }
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  /// URL-based avatar picker: paste a direct image link with live preview.
  /// No Firebase Storage is used - the app runs on the free Firebase plan.
  Future<void> _editAvatar() async {
    final controller = TextEditingController(
      text: _avatarUrlDraft ?? _user?.avatarUrl ?? '',
    );
    await showNeoSheet<void>(
      context,
      title: 'AVATAR SOURCE // URL',
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final preview = value.text.trim();
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipOval(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB6FF00),
                        width: 2,
                      ),
                      color: const Color(0xFF161A18),
                    ),
                    child: preview.isNotEmpty
                        ? Image.network(
                            preview,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white38,
                              size: 32,
                            ),
                          )
                        : const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white38,
                            size: 32,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              neoTextField(
                controller: controller,
                hint: 'https://... direct image link',
                autofocus: true,
              ),
              const SizedBox(height: 12),
              neoPrimaryButton(
                label: 'APPLY',
                onTap: () {
                  final url = controller.text.trim();
                  if (url.isNotEmpty &&
                      !url.startsWith('http://') &&
                      !url.startsWith('https://')) {
                    showNeoError(
                      context,
                      'ERROR // URL MUST START WITH HTTP(S)://',
                    );
                    return;
                  }
                  setState(() => _avatarUrlDraft = url);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().replaceAll('@', '');

    if (name.isEmpty || username.isEmpty) {
      showNeoTip(context, 'NAME AND HANDLE ARE REQUIRED');
      return;
    }
    if (username.contains(' ')) {
      showNeoTip(context, 'HANDLE INVALID // NO SPACES');
      return;
    }

    setState(() => _saving = true);
    try {
      final currentUsername = _user?.username ?? '';
      if (username.toLowerCase() != currentUsername.toLowerCase()) {
        final taken = await AuthService.instance.isUsernameTaken(username);
        if (taken) {
          if (mounted) showNeoTip(context, 'HANDLE TAKEN // CHOOSE ANOTHER');
          return;
        }
      }

      if (_avatarUrlDraft != null) {
        await UserService.instance.updateAvatarUrl(_uid, _avatarUrlDraft!);
      }
      await UserService.instance.updateProfile(
        _uid,
        name: name,
        username: username,
        bio: _bio,
        pronouns: _pronouns,
        website: _websiteController.text,
      );
      if (!mounted) return;
      showNeoTip(context, 'PROFILE UPDATED // SYNC COMPLETE');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) showNeoTip(context, 'SYNC FAULT // RETRY');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editTextValue({
    required String title,
    required String hint,
    required String current,
    required ValueChanged<String> onSave,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: current);
    await showNeoSheet<void>(
      context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          neoTextField(
            controller: controller,
            hint: hint,
            autofocus: true,
            maxLines: maxLines,
          ),
          const SizedBox(height: 12),
          neoPrimaryButton(
            label: 'APPLY',
            onTap: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _avatarUrlDraft ?? _user?.avatarUrl ?? '';

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
          'EDIT PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'DONE ✓',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFB6FF00),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Privacy Notice Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SECURITY NOTICE // Keep your personal details private. Information you add here is visible to anyone who can view your profile.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Avatar & Change Button
                  Center(
                    child: Column(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFB6FF00),
                                width: 2.5,
                              ),
                              color: const Color(0xFF161A18),
                            ),
                            child: avatarUrl.isNotEmpty
                                ? Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white38,
                                      size: 40,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white38,
                                    size: 40,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _editAvatar,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161A18),
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'EDIT AVATAR',
                              style: TextStyle(
                                color: Color(0xFFB6FF00),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Input Fields Section
                  _buildInputField(
                    'NAME // OPERATOR',
                    _nameController,
                    maxLength: 65,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField('USERNAME', _usernameController),
                  const SizedBox(height: 12),
                  _buildNavField(
                    'PRONOUNS',
                    _pronouns.isEmpty
                        ? 'Share how you like to be referred to'
                        : _pronouns,
                    onTap: () => _editTextValue(
                      title: 'SET PRONOUNS',
                      hint: 'e.g. he/him',
                      current: _pronouns,
                      onSave: (value) => setState(() => _pronouns = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNavField(
                    'ABOUT // BIO',
                    _bio.isEmpty ? 'Tell your curator story' : _bio,
                    onTap: () => _editTextValue(
                      title: 'SET CURATOR STORY',
                      hint: 'Tell your curator story',
                      current: _bio,
                      maxLines: 4,
                      onSave: (value) => setState(() => _bio = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    'WEBSITE LINK',
                    _websiteController,
                    hint: 'Add a link to drive traffic to your vault',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int? maxLength,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: Colors.white24, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLength: maxLength,
            autocorrect: false,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              isDense: true,
              counterText: maxLength != null ? null : '',
              counterStyle: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavField(String label, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161A18),
          border: Border.all(color: Colors.white24, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}
