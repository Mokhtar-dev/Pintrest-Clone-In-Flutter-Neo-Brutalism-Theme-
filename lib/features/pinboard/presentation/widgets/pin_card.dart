import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/pin.dart';

/// The masonry feed card. Visuals are identical to the original hardcoded
/// home feed card - only the data source and tap handlers are dynamic now.
class PinCard extends StatelessWidget {
  final Pin pin;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onLike;
  final VoidCallback? onMore;
  final bool isLiked;
  final bool isSaved;

  const PinCard({
    super.key,
    required this.pin,
    this.onTap,
    this.onSave,
    this.onLike,
    this.onMore,
    this.isLiked = false,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161A18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: pin.aspectRatio == 0 ? 0.75 : pin.aspectRatio,
                  child: Image.network(
                    pin.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFF0F1110),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFB6FF00),
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF0F1110),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white38,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(pin.badgeColor),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      pin.badge,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB6FF00),
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 12,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'SAVE',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pin.categoryLabel,
                          style: const TextStyle(
                            color: Color(0xFFFF0055),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.bookmark_outline,
                            size: 10,
                            color: Color(0xFFB6FF00),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            formatCount(pin.savesCount),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pin.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pin.authorUsername,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onLike,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? const Color(0xFFFF0055)
                                    : Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onMore,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
