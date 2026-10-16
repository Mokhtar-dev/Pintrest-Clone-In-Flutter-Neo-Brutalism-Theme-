import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/pinboard/domain/entities/board.dart';
import '../features/pinboard/domain/entities/pin.dart';

/// Board ("moodboard vault") operations under `users/{uid}/boards`.
class BoardService {
  BoardService._();
  static final BoardService instance = BoardService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _boards(String uid) =>
      _db.collection('users').doc(uid).collection('boards');

  Stream<List<Board>> streamBoards(String uid) {
    if (uid.isEmpty) return Stream.value(const []);
    return _boards(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Board.fromDoc).toList());
  }

  Stream<Board?> streamBoard(String uid, String boardId) {
    if (uid.isEmpty || boardId.isEmpty) return Stream.value(null);
    return _boards(uid).doc(boardId).snapshots().map((doc) {
      return doc.exists ? Board.fromDoc(doc) : null;
    });
  }

  Future<String> createBoard(String uid, String name) async {
    final doc = await _boards(uid).add({
      'name': name.trim().toUpperCase(),
      'coverImageUrl': '',
      'pinCount': 0,
      'pinIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(uid).update({
      'boardsCount': FieldValue.increment(1),
    });
    return doc.id;
  }

  Future<void> deleteBoard(String uid, String boardId) async {
    await _boards(uid).doc(boardId).delete();
    await _db.collection('users').doc(uid).update({
      'boardsCount': FieldValue.increment(-1),
    });
  }

  /// Fetches the pins stored inside a board (batched `whereIn` lookups).
  Future<List<Pin>> getBoardPins(List<String> pinIds) async {
    if (pinIds.isEmpty) return const [];
    final pins = <Pin>[];
    for (var i = 0; i < pinIds.length; i += 30) {
      final chunk = pinIds.sublist(
        i,
        i + 30 > pinIds.length ? pinIds.length : i + 30,
      );
      final snap = await _db
          .collection('pins')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      pins.addAll(snap.docs.map(Pin.fromDoc));
    }
    return pins;
  }
}
