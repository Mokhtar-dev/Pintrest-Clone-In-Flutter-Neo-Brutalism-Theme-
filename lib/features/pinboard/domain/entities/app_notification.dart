import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types supported by the live feed (docs under
/// `users/{uid}/notifications`).
class AppNotification {
  static const String typeLike = 'LIKE';
  static const String typeSave = 'SAVE';
  static const String typeFollow = 'FOLLOW';
  static const String typeComment = 'COMMENT';

  final String id;
  final String type;
  final String actorId;
  final String actorName;
  final String actorUsername;
  final String actorAvatarUrl;
  final String pinId;
  final String pinTitle;
  final String commentText;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    this.actorId = '',
    this.actorName = '',
    this.actorUsername = '',
    this.actorAvatarUrl = '',
    this.pinId = '',
    this.pinTitle = '',
    this.commentText = '',
    this.read = false,
    this.createdAt,
  });

  /// Terminal style handle shown in the feed (falls back to the name).
  String get handle => '@${actorUsername.isNotEmpty ? actorUsername : actorName}';

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return AppNotification(
      id: doc.id,
      type: map['type'] as String? ?? AppNotification.typeLike,
      actorId: map['actorId'] as String? ?? '',
      actorName: map['actorName'] as String? ?? '',
      actorUsername: map['actorUsername'] as String? ?? '',
      actorAvatarUrl: map['actorAvatarUrl'] as String? ?? '',
      pinId: map['pinId'] as String? ?? '',
      pinTitle: map['pinTitle'] as String? ?? '',
      commentText: map['commentText'] as String? ?? '',
      read: map['read'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Human readable action line rendered inside the notification tile.
  String get actionText {
    switch (type) {
      case typeSave:
        return 'saved your drop to board';
      case typeFollow:
        return 'started following your stream';
      case typeComment:
        final preview = commentText.length > 40
            ? '${commentText.substring(0, 40)}...'
            : commentText;
        return 'commented: "$preview" on';
      case typeLike:
      default:
        return 'liked your drop';
    }
  }
}
