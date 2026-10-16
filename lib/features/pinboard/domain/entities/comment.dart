import 'package:cloud_firestore/cloud_firestore.dart';

/// A comment ("discourse note") on a pin (docs under `pins/{pinId}/comments`).
class Comment {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.text,
    this.authorId = '',
    this.authorName = '',
    this.authorAvatarUrl = '',
    this.createdAt,
  });

  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return Comment(
      id: doc.id,
      text: map['text'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorAvatarUrl: map['authorAvatarUrl'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
