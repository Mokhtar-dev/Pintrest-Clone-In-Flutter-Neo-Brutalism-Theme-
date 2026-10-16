import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../services/pin_service.dart';
import '../../domain/entities/pin.dart';
import '../widgets/neo_feedback.dart';
import '../widgets/pin_card.dart';
import 'image_details_screen.dart';

/// EXPLORE tab: live search over the pin database, styled with the same
/// terminal header/search field/masonry grid used across the app.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String _query = '';

  final List<String> _categories = [
    'ALL',
    'ACID GRAPHICS',
    '3D CLAY',
    'RAW TYPOGRAPHY',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pin> _applyFilters(List<Pin> pins) {
    var result = pins;
    if (_selectedCategoryIndex > 0) {
      final category = _categories[_selectedCategoryIndex];
      result = result.where((pin) => pin.category == category).toList();
    }
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((pin) {
        return pin.title.toLowerCase().contains(query) ||
            pin.category.toLowerCase().contains(query) ||
            pin.categoryLabel.toLowerCase().contains(query) ||
            pin.authorUsername.toLowerCase().contains(query) ||
            pin.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Header Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFFB6FF00), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'EXPLORE DATABASE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              StreamBuilder<List<Pin>>(
                stream: PinService.instance.streamPins(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$count DROPS INDEXED',
                      style: const TextStyle(
                        color: Color(0xFFB6FF00),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 2. Search Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161A18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search visual database...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Filter Pills Horizontal List
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB6FF00)
                        : const Color(0xFF161A18),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.white24,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // 4. Results Grid
        Expanded(
          child: StreamBuilder<List<Pin>>(
            stream: PinService.instance.streamPins(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const NeoEmptyState(
                  title: 'SCANNING DATABASE',
                  subtitle: 'SYSTEM MODULE INITIALIZING...',
                );
              }
              final pins = _applyFilters(snapshot.data ?? const <Pin>[]);
              if (pins.isEmpty) {
                return const NeoEmptyState(
                  icon: Icons.search_off,
                  title: 'NO MATCHES FOUND',
                  subtitle: 'ADJUST QUERY OR FILTER CHANNEL',
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: pins.length,
                  itemBuilder: (context, index) {
                    final pin = pins[index];
                    return PinCard(
                      pin: pin,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDetailsScreen(pin: pin),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
