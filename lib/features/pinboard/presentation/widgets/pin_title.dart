import 'package:flutter/material.dart';
import '../../domain/entities/pin.dart';
import 'neo_brutalist_card.dart';

class PinTile extends StatelessWidget {
  final Pin pin;
  final VoidCallback onTap;

  const PinTile({
    super.key,
    required this.pin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoBrutalistCard(
        backgroundColor: Colors.amberAccent.shade100, // Cyber/Neo-brutalist accent
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder / Network Image
            Expanded(
              child: Image.network(
                pin.imageUrl,
                fit: BoxFit.cover,
                // Fallback while loading
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.red.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.black, size: 32),
                  ),
                ),
              ),
            ),
            // Pin Details Footer
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black, width: 3.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pin.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite_border, size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        '${pin.likesCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
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