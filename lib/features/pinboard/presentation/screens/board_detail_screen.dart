import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/board_service.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/pin.dart';
import '../widgets/neo_feedback.dart';
import '../widgets/pin_card.dart';
import 'image_details_screen.dart';

/// Displays every drop stored inside one board vault.
class BoardDetailScreen extends StatelessWidget {
  final Board board;

  const BoardDetailScreen({super.key, required this.board});

  String get _uid => AuthService.instance.currentUid;

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
        title: Text(
          board.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF161A18),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${board.pinCount} PINS',
                  style: const TextStyle(
                    color: Color(0xFFB6FF00),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<Board?>(
        stream: BoardService.instance.streamBoard(_uid, board.id),
        builder: (context, boardSnapshot) {
          final liveBoard = boardSnapshot.data ?? board;
          return FutureBuilder<List<Pin>>(
            future: BoardService.instance.getBoardPins(liveBoard.pinIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const NeoEmptyState(
                  title: 'DECRYPTING VAULT',
                  subtitle: 'SYSTEM MODULE INITIALIZING...',
                );
              }
              final pins = snapshot.data ?? const <Pin>[];
              if (pins.isEmpty) {
                return const NeoEmptyState(
                  icon: Icons.lock_outline,
                  title: 'VAULT EMPTY',
                  subtitle: 'DROP DROPS INTO THIS BOARD FROM ANY PIN',
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
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
          );
        },
      ),
    );
  }
}
