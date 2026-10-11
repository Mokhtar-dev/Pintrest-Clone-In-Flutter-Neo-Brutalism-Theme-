import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock list of pins to display for frontend testing
  final List<Map<String, String>> _mockPins = [
    {
      'title': 'Cyberpunk Alley',
      'author': 'operator_01',
      'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    },
    {
      'title': 'Neon Grid Layout',
      'author': 'cyber_ninja',
      'image': 'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
    },
    {
      'title': 'Terminal Matrix',
      'author': 'root_admin',
      'image': 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5',
    },
    {
      'title': 'Abstract Glass',
      'author': 'pixel_pusher',
      'image': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D0C),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB6FF00),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'IMAGMANIA // FEED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Profile Icon Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person, color: Color(0xFFB6FF00), size: 20),
                      onPressed: () {
                        // TODO: Navigate to Profile Screen
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161A18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search visual database...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section Label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'ALL UPLOADED ASSETS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Grid View of Images (Dashboard requirement)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  itemCount: _mockPins.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final pin = _mockPins[index];
                    return GestureDetector(
                      onTap: () {
                        // TODO: Navigate to Image Details Screen
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24, width: 1.5),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                pin['image']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pin['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'by ${pin['author']}',
                                    style: const TextStyle(
                                      color: Color(0xFFB6FF00),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
      // Floating Action Button to add new image
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB6FF00),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          // TODO: Open Add Image Screen / Dialog
        },
      ),
    );
  }
} 