import 'package:cloud_firestore/cloud_firestore.dart';

/*This is the basic definition of a pin or a post */
class Pin {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String categoryLabel;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String authorAvatarUrl;
  final int likesCount;
  final int savesCount;
  final int commentsCount;
  final double aspectRatio;
  final String badge;
  final int badgeColor;
  final String storagePath;
  final DateTime? createdAt;

  const Pin({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.authorName,
    required this.likesCount,
    this.description = '',
    this.category = 'ALL',
    this.categoryLabel = 'FRESH DROP',
    this.tags = const [],
    this.authorId = '',
    this.authorUsername = '',
    this.authorAvatarUrl = '',
    this.savesCount = 0,
    this.commentsCount = 0,
    this.aspectRatio = 0.75,
    this.badge = 'FRESH DROP',
    this.badgeColor = 0xFFB6FF00,
    this.storagePath = '',
    this.createdAt,
  });

  factory Pin.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Pin.fromMap(doc.id, doc.data() ?? const {});
  }

  factory Pin.fromMap(String id, Map<String, dynamic> map) {
    return Pin(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? 'ALL',
      categoryLabel: map['categoryLabel'] as String? ?? 'FRESH DROP',
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorUsername: map['authorUsername'] as String? ?? '',
      authorAvatarUrl: map['authorAvatarUrl'] as String? ?? '',
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      savesCount: (map['savesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      aspectRatio: (map['aspectRatio'] as num?)?.toDouble() ?? 0.75,
      badge: map['badge'] as String? ?? 'FRESH DROP',
      badgeColor: (map['badgeColor'] as num?)?.toInt() ?? 0xFFB6FF00,
      storagePath: map['storagePath'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'categoryLabel': categoryLabel,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatarUrl': authorAvatarUrl,
      'likesCount': likesCount,
      'savesCount': savesCount,
      'commentsCount': commentsCount,
      'aspectRatio': aspectRatio,
      'badge': badge,
      'badgeColor': badgeColor,
      'storagePath': storagePath,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
