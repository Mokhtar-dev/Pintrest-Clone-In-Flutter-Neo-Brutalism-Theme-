import 'package:cloud_firestore/cloud_firestore.dart';

/// A moodboard / vault created by a user (docs under `users/{uid}/boards`).
class Board {
  final String id;
  final String name;
  final String coverImageUrl;
  final int pinCount;
  final List<String> pinIds;
  final DateTime? createdAt;

  const Board({
    required this.id,
    required this.name,
    this.coverImageUrl = '',
    this.pinCount = 0,
    this.pinIds = const [],
    this.createdAt,
  });

  factory Board.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return Board(
      id: doc.id,
      name: map['name'] as String? ?? 'UNTITLED VAULT',
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      pinCount: (map['pinCount'] as num?)?.toInt() ?? 0,
      pinIds: (map['pinIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'coverImageUrl': coverImageUrl,
      'pinCount': pinCount,
      'pinIds': pinIds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
