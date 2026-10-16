import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../features/pinboard/domain/entities/app_notification.dart';
import '../features/pinboard/domain/entities/app_user.dart';
import '../features/pinboard/domain/entities/comment.dart';
import '../features/pinboard/domain/entities/pin.dart';
import 'notification_service.dart';

/// All pin related Firestore/Storage operations: CRUD, likes, saves,
/// comments, boards assignment and demo seeding.
class PinService {
  PinService._();
  static final PinService instance = PinService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _pins => _db.collection('pins');

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Live feed of every drop, newest first.
  Stream<List<Pin>> streamPins() {
    return _pins
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(Pin.fromDoc).toList());
  }

  Stream<Pin?> streamPin(String pinId) {
    if (pinId.isEmpty) return Stream.value(null);
    return _pins.doc(pinId).snapshots().map((doc) {
      return doc.exists ? Pin.fromDoc(doc) : null;
    });
  }

  Future<Pin?> getPin(String pinId) async {
    if (pinId.isEmpty) return null;
    final doc = await _pins.doc(pinId).get();
    return doc.exists ? Pin.fromDoc(doc) : null;
  }

  Stream<List<Pin>> streamSavedPins(String uid) {
    if (uid.isEmpty) return Stream.value(const []);
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Pin.fromDoc).toList());
  }

  Stream<bool> streamIsSaved(String uid, String pinId) {
    if (uid.isEmpty || pinId.isEmpty) return Stream.value(false);
    return _db
        .collection('users')
        .doc(uid)
        .collection('saved')
        .doc(pinId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<bool> streamIsLiked(String pinId, String uid) {
    if (uid.isEmpty || pinId.isEmpty) return Stream.value(false);
    return _pins
        .doc(pinId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ---------------------------------------------------------------------------
  // Pin creation
  // ---------------------------------------------------------------------------

  /// Uploads the image to Storage and stores the metadata document.
  Future<String> createPin({
    required Uint8List bytes,
    required String title,
    required String description,
    required double aspectRatio,
    required AppUser author,
    String category = 'ALL',
    String categoryLabel = 'FRESH DROP',
    List<String> tags = const [],
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'pins/${author.uid}/$timestamp.jpg';
    final storageRef = _storage.ref(storagePath);
    await storageRef.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await storageRef.getDownloadURL();

    final doc = await _pins.add({
      'title': title.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl,
      'category': category,
      'categoryLabel': categoryLabel,
      'tags': tags,
      'authorId': author.uid,
      'authorName': author.name,
      'authorUsername': author.username,
      'authorAvatarUrl': author.avatarUrl,
      'likesCount': 0,
      'savesCount': 0,
      'commentsCount': 0,
      'aspectRatio': aspectRatio,
      'badge': 'FRESH DROP',
      'badgeColor': 0xFFB6FF00,
      'storagePath': storagePath,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(author.uid).update({
      'pinsCount': FieldValue.increment(1),
    });
    return doc.id;
  }

  Future<void> deletePin(Pin pin) async {
    if (pin.storagePath.isNotEmpty) {
      try {
        await _storage.ref(pin.storagePath).delete();
      } catch (_) {
        // File may already be gone - keep deleting the document.
      }
    }
    await _pins.doc(pin.id).delete();
    if (pin.authorId.isNotEmpty) {
      await _db.collection('users').doc(pin.authorId).update({
        'pinsCount': FieldValue.increment(-1),
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Likes
  // ---------------------------------------------------------------------------

  /// Toggles like state. Returns the new state (true = liked).
  Future<bool> toggleLike({
    required Pin pin,
    required String uid,
    required String actorName,
    required String actorUsername,
    required String actorAvatarUrl,
  }) async {
    final likeRef = _pins.doc(pin.id).collection('likes').doc(uid);
    final existing = await likeRef.get();

    if (existing.exists) {
      final batch = _db.batch();
      batch.delete(likeRef);
      batch.update(_pins.doc(pin.id), {
        'likesCount': FieldValue.increment(-1),
      });
      await batch.commit();
      return false;
    }

    final batch = _db.batch();
    batch.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
    batch.update(_pins.doc(pin.id), {
      'likesCount': FieldValue.increment(1),
    });
    await batch.commit();

    await NotificationService.instance.create(
      recipientId: pin.authorId,
      type: AppNotification.typeLike,
      actorId: uid,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatarUrl: actorAvatarUrl,
      pinId: pin.id,
      pinTitle: pin.title,
    );
    return true;
  }

  // ---------------------------------------------------------------------------
  // Saves (to the personal SAVED vault and/or a board)
  // ---------------------------------------------------------------------------

  /// Saves [pin] into the user's SAVED vault. Returns false when it was
  /// already saved (counters and notifications are then skipped).
  Future<bool> savePinToSaved({
    required Pin pin,
    required String uid,
    required String actorName,
    required String actorUsername,
    required String actorAvatarUrl,
    String? boardName,
  }) async {
    final saveRef = _pins.doc(pin.id).collection('savedBy').doc(uid);
    final existing = await saveRef.get();
    if (existing.exists) return false;

    final batch = _db.batch();
    batch.set(saveRef, {'savedAt': FieldValue.serverTimestamp()});
    batch.set(
      _db.collection('users').doc(uid).collection('saved').doc(pin.id),
      {
        ...pin.toMap(),
        'savedAt': FieldValue.serverTimestamp(),
      },
    );
    batch.update(_pins.doc(pin.id), {
      'savesCount': FieldValue.increment(1),
    });
    if (pin.authorId.isNotEmpty) {
      batch.update(_db.collection('users').doc(pin.authorId), {
        'savesReceived': FieldValue.increment(1),
      });
    }
    await batch.commit();

    await NotificationService.instance.create(
      recipientId: pin.authorId,
      type: AppNotification.typeSave,
      actorId: uid,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatarUrl: actorAvatarUrl,
      pinId: pin.id,
      pinTitle: boardName ?? pin.title,
    );
    return true;
  }

  /// Saves a pin into one of the user's boards (also records it in SAVED).
  Future<bool> savePinToBoard({
    required Pin pin,
    required String uid,
    required String boardId,
    required String boardName,
    required String actorName,
    required String actorUsername,
    required String actorAvatarUrl,
  }) async {
    final boardRef = _db
        .collection('users')
        .doc(uid)
        .collection('boards')
        .doc(boardId);

    await boardRef.update({
      'pinIds': FieldValue.arrayUnion([pin.id]),
      'pinCount': FieldValue.increment(1),
    });
    final boardDoc = await boardRef.get();
    if ((boardDoc.data()?['coverImageUrl'] as String? ?? '').isEmpty) {
      await boardRef.update({'coverImageUrl': pin.imageUrl});
    }

    return savePinToSaved(
      pin: pin,
      uid: uid,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatarUrl: actorAvatarUrl,
      boardName: boardName,
    );
  }

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  Stream<List<Comment>> streamComments(String pinId) {
    if (pinId.isEmpty) return Stream.value(const []);
    return _pins
        .doc(pinId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(Comment.fromDoc).toList());
  }

  Future<void> addComment({
    required Pin pin,
    required String uid,
    required String actorName,
    required String actorUsername,
    required String actorAvatarUrl,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _pins.doc(pin.id).collection('comments').add({
      'text': trimmed,
      'authorId': uid,
      'authorName': actorName,
      'authorAvatarUrl': actorAvatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _pins.doc(pin.id).update({
      'commentsCount': FieldValue.increment(1),
    });

    await NotificationService.instance.create(
      recipientId: pin.authorId,
      type: AppNotification.typeComment,
      actorId: uid,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatarUrl: actorAvatarUrl,
      pinId: pin.id,
      pinTitle: pin.title,
      commentText: trimmed,
    );
  }

  // ---------------------------------------------------------------------------
  // Demo seeding
  // ---------------------------------------------------------------------------

  /// Writes the four showcase drops once, so the feed keeps the exact look of
  /// the original mock design on an empty Firebase project.
  Future<void> seedSamplePinsIfEmpty() async {
    final existing = await _pins.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final seeds = <Map<String, dynamic>>[
      {
        'title': 'SYSTEM MATRIX 04',
        'description':
            'High-density kinetic scan study derived from early Swiss typographic principles merged with mid-90s underground club flyers.',
        'imageUrl':
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
        'category': 'ACID GRAPHICS',
        'categoryLabel': 'POSTER // GRID',
        'tags': ['#TYPOGRAPHY', '#ACIDGRAPHICS', '#NEOBRUTALISM', '#SWISSPOSTER'],
        'authorUsername': '@studio_ke_',
        'authorAvatarUrl': 'https://i.pravatar.cc/100?img=33',
        'likesCount': 2861,
        'savesCount': 1400,
        'badge': 'SPARK ★',
        'badgeColor': 0xFFFFF500,
        'aspectRatio': 0.70,
        'ageMinutes': 5,
      },
      {
        'title': 'MERCURY SPHERE',
        'description':
            'Liquid chrome render experiment exploring reflective brutalist silhouettes.',
        'imageUrl':
            'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
        'category': '3D CLAY',
        'categoryLabel': '3D CHROME',
        'tags': ['#3DRENDER', '#CHROME', '#NEOBRUTALISM'],
        'authorUsername': '@acid_vault',
        'authorAvatarUrl': 'https://i.pravatar.cc/100?img=47',
        'likesCount': 1540,
        'savesCount': 890,
        'badge': 'CHROME LOVE',
        'badgeColor': 0xFFFF0055,
        'aspectRatio': 0.90,
        'ageMinutes': 65,
      },
      {
        'title': 'MONOLITH BUNKER 9',
        'description':
            'Raw concrete interiors scanned from an abandoned cold-war substation.',
        'imageUrl':
            'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5',
        'category': 'RAW TYPOGRAPHY',
        'categoryLabel': 'INTERIOR ARCH',
        'tags': ['#ARCHITECTURE', '#BRUTALISM', '#CONCRETE'],
        'authorUsername': '@archidrop',
        'authorAvatarUrl': 'https://i.pravatar.cc/100?img=60',
        'likesCount': 4200,
        'savesCount': 2100,
        'badge': 'BRUTAL_SPACE',
        'badgeColor': 0xFF00E5FF,
        'aspectRatio': 0.65,
        'ageMinutes': 180,
      },
      {
        'title': 'FLORA OVERLAY 09',
        'description':
            'Riso print overlay series blending organic flora with machine noise.',
        'imageUrl':
            'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
        'category': 'ACID GRAPHICS',
        'categoryLabel': 'RISO // PRINT',
        'tags': ['#RISO', '#PRINT', '#FLORA'],
        'authorUsername': '@risolab',
        'authorAvatarUrl': 'https://i.pravatar.cc/100?img=12',
        'likesCount': 980,
        'savesCount': 3800,
        'badge': 'NEW DROP',
        'badgeColor': 0xFFB6FF00,
        'aspectRatio': 0.81,
        'ageMinutes': 1440,
      },
    ];

    final batch = _db.batch();
    for (final seed in seeds) {
      final ageMinutes = seed.remove('ageMinutes') as int;
      final doc = _pins.doc();
      batch.set(doc, {
        ...seed,
        'authorId': 'pindrop_archive',
        'authorName': 'PIN/DROP ARCHIVE',
        'commentsCount': 1,
        'storagePath': '',
        'createdAt': Timestamp.fromDate(
          now.subtract(Duration(minutes: ageMinutes)),
        ),
        'tags': (seed['tags'] as List<String>)
            .map((tag) => tag.replaceFirst('#', ''))
            .toList(),
      });

      final comment = doc.collection('comments').doc();
      batch.set(comment, {
        'text':
            '"That diagonal baseline anchor break at the footer is pure genius. Printed copies had silver metallic spot-color."',
        'authorId': 'studio_helvetica',
        'authorName': '@studio_helvetica',
        'authorAvatarUrl': 'https://i.pravatar.cc/100?img=52',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
      });
    }
    await batch.commit();
  }
}
