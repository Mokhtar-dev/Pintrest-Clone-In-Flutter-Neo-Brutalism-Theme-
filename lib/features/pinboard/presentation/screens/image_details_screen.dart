import 'package:flutter/material.dart';

class ImageDetailsScreen extends StatelessWidget {
  const ImageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1110),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1110),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PIN DETAIL',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/100'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top URL & Sparks Tag Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A18),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('ARCHDIGEST.DESIGN', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.north_east, color: Color(0xFFB6FF00), size: 10),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF500),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.black, size: 14),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A18),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.upload_outlined, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Featured Image Container with Overlays
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(color: const Color(0xFFB6FF00), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 380,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: const Color(0xFFFF0055),
                      child: const Text('⚡ STAFF SPARK #984', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.black,
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: Color(0xFFB6FF00)),
                          SizedBox(width: 6),
                          Text('14 VIEWING LIVE', style: TextStyle(color: Color(0xFFB6FF00), fontWeight: FontWeight.w900, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Drop to Board Primary Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB6FF00),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text('DROP TO BOARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Interaction Bar (Likes, Remix, SVG)
            Row(
              children: [
                Expanded(child: _buildActionChip(Icons.favorite_border, '2,861')),
                const SizedBox(width: 8),
                Expanded(child: _buildActionChip(Icons.tune, 'REMIX', iconColor: const Color(0xFFFFF500))),
                const SizedBox(width: 8),
                Expanded(child: _buildActionChip(Icons.download, 'RAW SVG', iconColor: const Color(0xFFB6FF00))),
              ],
            ),
            const SizedBox(height: 20),

            // Pin Title & Description Meta
            Row(
              children: const [
                Text('ARCHIVE CODE: AG-409', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                SizedBox(width: 12),
                Text('RESTRICTED PRINT RUN', style: TextStyle(color: Color(0xFFFF0055), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'EXPERIMENTAL ACID GRID VOL. 04',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'High-density kinetic scan study derived from early Swiss typographic principles merged with mid-90s underground club flyers.',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),

            // Hashtag Pills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTagChip('#TYPOGRAPHY', const Color(0xFFFFF500)),
                _buildTagChip('#ACIDGRAPHICS', Colors.black, borderColor: Colors.white54),
                _buildTagChip('#NEOBRUTALISM', const Color(0xFFB6FF00)),
                _buildTagChip('#SWISSPOSTER', const Color(0xFFFF0055)),
              ],
            ),
            const SizedBox(height: 20),

            // Author Profile Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@rave_typography', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        Text('48.2K COLLECTORS', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF500),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {},
                    child: const Text('FOLLOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Discourse / Comment Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('DISCOURSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: const Color(0xFF161A18),
                      child: const Text('18', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                const Text('WRITE NOTE', style: TextStyle(color: Color(0xFFFF0055), fontWeight: FontWeight.w900, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),

            // Comment Note Item
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('@studio_helvetica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            color: const Color(0xFFB6FF00),
                            child: const Text('VERIFIED PRESS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 8)),
                          ),
                        ],
                      ),
                      const Text('3M AGO', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '"That diagonal baseline anchor break at the footer is pure genius. Printed copies had silver metallic spot-color."',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, {Color iconColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, Color color, {Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor ?? Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == Colors.black ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}