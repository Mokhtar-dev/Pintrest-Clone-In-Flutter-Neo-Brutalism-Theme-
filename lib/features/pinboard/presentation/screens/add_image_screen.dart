import 'package:flutter/material.dart';

class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  int _selectedRatio = 0; // 0: 3:4, 1: 1:1, 2: 9:16
  int _selectedAssetIndex = 0;

  final List<String> _galleryAssets = [
    'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420',
    'https://images.unsplash.com/photo-1579783902614-a3fb3927b675',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1110),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top HUD Header
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'UPLOAD DROP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB6FF00),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Proceed to final metadata input / upload
                        },
                        child: const Text(
                          'NEXT (1) →',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFB6FF00),
                        child: const Icon(Icons.person, color: Colors.black, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Storage Granted & Category Selector Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      children: [
                        Text('RECENTS (1,420)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(width: 6, height: 6, color: const Color(0xFFB6FF00)),
                      const SizedBox(width: 6),
                      const Text('STORAGE // GRANTED', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['RECENTS', 'SCREENSHOTS', '3D RENDERS', 'GRAPHIC ASSETS'].map((tab) {
                  final isSelected = tab == 'RECENTS';
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFB6FF00) : const Color(0xFF161A18),
                      border: Border.all(color: isSelected ? Colors.black : Colors.white24),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Main Preview Terminal Window
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A18),
                    border: Border.all(color: const Color(0xFFB6FF00), width: 2),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          _galleryAssets[_selectedAssetIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Top Badges Overlay
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          color: const Color(0xFFB6FF00),
                          child: const Text('SELECTED: 01 / 10', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9)),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          color: const Color(0xFF00E5FF),
                          child: const Text('PREVIEW // 3840×2160', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9)),
                        ),
                      ),
                      // Bottom Target Tag
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: Colors.black,
                          child: const Text('PIN_TARGET: VECT_098', style: TextStyle(color: Color(0xFFB6FF00), fontWeight: FontWeight.w900, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Aspect Ratio & Tools Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text('RATIO: ', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10)),
                  _buildRatioChip('3:4', 0),
                  _buildRatioChip('1:1', 1),
                  _buildRatioChip('9:16', 2),
                  const Spacer(),
                  _buildToolButton(Icons.crop_rounded, 'CROP'),
                  const SizedBox(width: 6),
                  _buildToolButton(Icons.auto_fix_high, 'RAW_FX', isCyan: true),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Capture & Multi-Mode Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('CAPTURE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB6FF00),
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_on_rounded, color: Colors.black, size: 16),
                          SizedBox(width: 6),
                          Text('MULTI: ON', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Gallery Grid Index Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('GALLERY INDEX // STREAM_001', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8)),
                  Text('SORT: RECENT_FIRST', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Gallery Grid
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _galleryAssets.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_outlined, color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text('NEW SHOT\nREC // LIVE', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 9)),
                          ],
                        ),
                      );
                    }
                    final assetIndex = index - 1;
                    final isSelected = _selectedAssetIndex == assetIndex;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedAssetIndex = assetIndex),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? const Color(0xFFB6FF00) : Colors.white24,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(_galleryAssets[assetIndex], fit: BoxFit.cover),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  color: const Color(0xFFB6FF00),
                                  child: const Text('01', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom Continue Bar
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF0F1110),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 6, height: 6, color: const Color(0xFFB6FF00)),
                          const SizedBox(width: 6),
                          const Text('ARCHIVE_IMG_9921.PNG (4.2 MB)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 10)),
                        ],
                      ),
                      const Row(
                        children: [
                          Icon(Icons.check_box_outline_blank, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('CAROUSEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB6FF00),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CONTINUE WITH 1 DROP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
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

  Widget _buildRatioChip(String label, int index) {
    final isSelected = _selectedRatio == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRatio = index),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB6FF00) : const Color(0xFF161A18),
          border: Border.all(color: isSelected ? Colors.black : Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, {bool isCyan = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: isCyan ? const Color(0xFF00E5FF) : Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: isCyan ? const Color(0xFF00E5FF) : Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isCyan ? const Color(0xFF00E5FF) : Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
        ],
      ),
    );
  }
}