
/*This is the basic definition of a pin or a post */
class Pin {
  final String id;
  final String title;
  final String imageUrl;
  final String authorName;
  final int likesCount;

  const Pin({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.authorName,
    required this.likesCount,
  });
}