import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore model for a registered operator (docs under `users/{uid}`).
class AppUser {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String bio;
  final String pronouns;
  final String website;
  final String avatarUrl;
  final int pinsCount;
  final int boardsCount;
  final int savesReceived;
  final int followersCount;
  final int followingCount;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.username,
    this.email = '',
    this.bio = '',
    this.pronouns = '',
    this.website = '',
    this.avatarUrl = '',
    this.pinsCount = 0,
    this.boardsCount = 0,
    this.savesReceived = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AppUser.fromMap(doc.id, doc.data() ?? const {});
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      pronouns: map['pronouns'] as String? ?? '',
      website: map['website'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      pinsCount: (map['pinsCount'] as num?)?.toInt() ?? 0,
      boardsCount: (map['boardsCount'] as num?)?.toInt() ?? 0,
      savesReceived: (map['savesReceived'] as num?)?.toInt() ?? 0,
      followersCount: (map['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (map['followingCount'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'pronouns': pronouns,
      'website': website,
      'avatarUrl': avatarUrl,
      'pinsCount': pinsCount,
      'boardsCount': boardsCount,
      'savesReceived': savesReceived,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': createdAt,
    };
  }
}
