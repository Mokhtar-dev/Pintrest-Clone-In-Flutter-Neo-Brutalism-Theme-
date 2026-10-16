import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/pinboard/domain/entities/app_notification.dart';

/// Handles the live feed notifications stored under
/// `users/{recipientUid}/notifications`.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _feed(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  Stream<List<AppNotification>> streamNotifications(String uid) {
    if (uid.isEmpty) return Stream.value(const []);
    return _feed(uid)
        .orderBy('createdAt', descending: true)
        .limit(60)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  Stream<int> streamUnreadCount(String uid) {
    if (uid.isEmpty) return Stream.value(0);
    return _feed(uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markAllRead(String uid) async {
    final unread = await _feed(uid).where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> markRead(String uid, String notificationId) {
    return _feed(uid).doc(notificationId).update({'read': true});
  }

  /// Creates a notification for [recipientId]. Never notifies the actor
  /// about their own action (like/comment/save on own pin).
  Future<void> create({
    required String recipientId,
    required String type,
    required String actorId,
    required String actorName,
    required String actorAvatarUrl,
    String actorUsername = '',
    String pinId = '',
    String pinTitle = '',
    String commentText = '',
  }) async {
    if (recipientId.isEmpty || recipientId == actorId) return;
    await _feed(recipientId).add({
      'type': type,
      'actorId': actorId,
      'actorName': actorName,
      'actorUsername': actorUsername,
      'actorAvatarUrl': actorAvatarUrl,
      'pinId': pinId,
      'pinTitle': pinTitle,
      'commentText': commentText,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
