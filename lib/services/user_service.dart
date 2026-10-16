import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/pinboard/domain/entities/app_notification.dart';
import '../features/pinboard/domain/entities/app_user.dart';
import 'notification_service.dart';

/// Reads and writes operator profiles (`users/{uid}`) plus follow graph.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  /// Returns the signed-in operator profile, self-healing it when the
  /// Firestore document is missing (account created straight in the Firebase
  /// console, wiped database, or a registration write that failed halfway).
  /// Returns null only when nobody is signed in.
  Future<AppUser?> ensureUserProfile() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return null;

    final existing = await getUser(authUser.uid);
    if (existing != null) return existing;

    final email = (authUser.email ?? '').trim();
    final displayName = (authUser.displayName ?? '').trim();
    final rawHandle =
        displayName.isNotEmpty ? displayName : email.split('@').first;
    var handle = rawHandle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    if (handle.isEmpty) handle = 'operator';

    final clash =
        await _users.where('username', isEqualTo: handle).limit(1).get();
    if (clash.docs.isNotEmpty) {
      handle = '$handle${authUser.uid.substring(0, 4).toLowerCase()}';
    }

    await _users.doc(authUser.uid).set({
      'name': handle.toUpperCase(),
      'username': handle,
      'email': email,
      'bio': '',
      'pronouns': '',
      'website': '',
      'avatarUrl': '',
      'pinsCount': 0,
      'boardsCount': 0,
      'savesReceived': 0,
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return getUser(authUser.uid);
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

  /// Patches `avatarUrl` on the profile with a direct image link.
  /// No Firebase Storage is used - the app runs on the free Firebase plan.
  Future<void> updateAvatarUrl(String uid, String url) {
    return _users.doc(uid).update({'avatarUrl': url.trim()});
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
