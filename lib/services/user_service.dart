import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../features/pinboard/domain/entities/app_notification.dart';
import '../features/pinboard/domain/entities/app_user.dart';
import 'notification_service.dart';

/// Reads and writes operator profiles (`users/{uid}`) plus follow graph.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Stream<AppUser?> streamUser(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _users
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);
  }

  Future<AppUser?> getUser(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  Future<void> updateProfile(
    String uid, {
    required String name,
    required String username,
    required String bio,
    required String pronouns,
    required String website,
  }) {
    return _users.doc(uid).update({
      'name': name.trim(),
      'username': username.trim().replaceAll('@', '').toLowerCase(),
      'bio': bio.trim(),
      'pronouns': pronouns.trim(),
      'website': website.trim(),
    });
  }

  /// Uploads a new avatar to Storage and patches `avatarUrl` on the profile.
  Future<String> uploadAvatar(String uid, Uint8List bytes) async {
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _users.doc(uid).update({'avatarUrl': url});
    return url;
  }

  // ---------------------------------------------------------------------------
  // Follow graph: users/{targetUid}/followers/{myUid} + counters.
  // ---------------------------------------------------------------------------

  Stream<bool> streamIsFollowing(String myUid, String targetUid) {
    if (myUid.isEmpty || targetUid.isEmpty) return Stream.value(false);
    return _users
        .doc(targetUid)
        .collection('followers')
        .doc(myUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Toggles follow state. Returns the resulting state (true = now following).
  Future<bool> toggleFollow({
    required String myUid,
    required String myName,
    required String myUsername,
    required String myAvatarUrl,
    required String targetUid,
  }) async {
    final followerRef = _users.doc(targetUid).collection('followers').doc(myUid);
    final followingRef =
        _users.doc(myUid).collection('following').doc(targetUid);
    final existing = await followerRef.get();

    if (existing.exists) {
      final batch = _db.batch();
      batch.delete(followerRef);
      batch.delete(followingRef);
      batch.update(_users.doc(targetUid), {
        'followersCount': FieldValue.increment(-1),
      });
      batch.update(_users.doc(myUid), {
        'followingCount': FieldValue.increment(-1),
      });
      await batch.commit();
      return false;
    }

    final batch = _db.batch();
    batch.set(followerRef, {'followedAt': FieldValue.serverTimestamp()});
    batch.set(followingRef, {'followedAt': FieldValue.serverTimestamp()});
    batch.update(_users.doc(targetUid), {
      'followersCount': FieldValue.increment(1),
    });
    batch.update(_users.doc(myUid), {
      'followingCount': FieldValue.increment(1),
    });
    await batch.commit();

    await NotificationService.instance.create(
      recipientId: targetUid,
      type: AppNotification.typeFollow,
      actorId: myUid,
      actorName: myName,
      actorUsername: myUsername,
      actorAvatarUrl: myAvatarUrl,
    );
    return true;
  }
}
