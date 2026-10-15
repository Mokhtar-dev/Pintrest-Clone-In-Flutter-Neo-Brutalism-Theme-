import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Pre-loaded with user profile details
  final TextEditingController _nameController = TextEditingController(text: 'Mokhtar Mohamed');
  final TextEditingController _usernameController = TextEditingController(text: 'generalmk122');
  final TextEditingController _websiteController = TextEditingController(text: '');

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                // TODO: Save updated profile data to Firebase Firestore
                Navigator.pop(context);
              },
              child: const Text(
                'DONE ✓',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
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
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, height: 1.3),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Avatar & Change Button
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFB6FF00), width: 2.5),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/200?img=12'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'EDIT AVATAR',
                      style: TextStyle(color: Color(0xFFB6FF00), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Input Fields Section
            _buildInputField('NAME // OPERATOR', _nameController, maxLength: 65),
            const SizedBox(height: 12),
            _buildInputField('USERNAME', _usernameController),
            const SizedBox(height: 12),
            _buildNavField('PRONOUNS', 'Share how you like to be referred to'),
            const SizedBox(height: 12),
            _buildNavField('ABOUT // BIO', 'Tell your curator story'),
            const SizedBox(height: 12),
            _buildInputField('WEBSITE LINK', _websiteController, hint: 'Add a link to drive traffic to your vault'),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int? maxLength, String? hint}) {
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
            style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              isDense: true,
              counterText: maxLength != null ? null : '',
              counterStyle: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavField(String label, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: Colors.white24, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
        ],
      ),
    );
  }
}