import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentNavIndex = 3; // Profile tab is active
  int _selectedTab = 0; // 0: Boards, 1: Saved

  final List<Map<String, dynamic>> _boards = [
    {
      'title': 'ACID VAULT',
      'pins': '42 PINS',
      'status': 'LOCKED',
      'statusColor': const Color(0xFFFF0055),
      'image': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
    },
    {
      'title': 'BRUTAL WEB',
      'pins': '38 PINS',
      'status': 'UPDATED',
      'statusColor': const Color(0xFFB6FF00),
      'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    },
    {
      'title': 'CHROME & 3D',
      'pins': '24 PINS',
      'status': 'HOT',
      'statusColor': const Color(0xFF00E5FF),
      'image': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5',
    },
    {
      'title': 'EDITORIAL',
      'pins': '19 PINS',
      'status': 'CURATED',
      'statusColor': const Color(0xFFFF0055),
      'image': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1110),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xFFB6FF00),
                      size: 16,
                    ),
                  ),
                  const Text(
                    'PIN / DROP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A18),
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Stack(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Color(0xFFFF0055),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB6FF00),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/100?img=12',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // 2. User Profile Header Card
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://i.pravatar.cc/200?img=12',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                color: const Color(0xFFFFF500),
                                child: const Text(
                                  '★ ONLINE',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'KIRA VANCE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFFB6FF00),
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '@KIRAVANCE',
                                style: TextStyle(
                                  color: Color(0xFFB6FF00),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Visual collector & graphic designer. Hoarding type specimens & chrom...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Stats Metric Boxes Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            '142',
                            'PINS',
                            const Color(0xFFFFF500),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatBox(
                            '18',
                            'BOARDS',
                            const Color(0xFFB6FF00),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatBox(
                            '12.4K',
                            'SAVES',
                            const Color(0xFFFF0055),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. Action Buttons (Edit Profile, Share, More)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF161A18),
                              side: const BorderSide(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.tune,
                              color: Color(0xFFB6FF00),
                              size: 16,
                            ),
                            label: const Text(
                              'EDIT PROFILE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161A18),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF161A18),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. Boards / Saved Tabs Selector
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? const Color(0xFF161A18)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _selectedTab == 0
                                      ? const Color(0xFFB6FF00)
                                      : Colors.white24,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'BOARDS (18)',
                                  style: TextStyle(
                                    color: _selectedTab == 0
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? const Color(0xFF161A18)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _selectedTab == 1
                                      ? const Color(0xFFB6FF00)
                                      : Colors.white24,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'SAVED (142)',
                                  style: TextStyle(
                                    color: _selectedTab == 1
                                        ? Colors.white
                                        : Colors.white54,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. Grid of Boards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _boards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, index) {
                        final board = _boards[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF161A18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Image.network(
                                      board['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: board['statusColor'],
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          board['status'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      board['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      board['pins'],
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 7. Start a Board Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A18),
                        border: Border.all(color: Colors.white24, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB6FF00),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'START A BOARD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'NEW MOODBOARD OR SECRET VAULT',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. Pro Tip Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF500),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.black, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'PRO TIP: DOUBLE TAP ANY BOARD TO COPY INVITE LINK',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String count, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: accentColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
