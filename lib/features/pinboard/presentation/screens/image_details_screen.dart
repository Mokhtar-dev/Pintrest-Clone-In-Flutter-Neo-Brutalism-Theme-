import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/board_service.dart';
import '../../../../services/pin_service.dart';
import '../../../../services/user_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/pin.dart';
import '../widgets/neo_feedback.dart';

class ImageDetailsScreen extends StatefulWidget {
  final Pin pin;

  const ImageDetailsScreen({super.key, required this.pin});

  @override
  State<ImageDetailsScreen> createState() => _ImageDetailsScreenState();
}

class _ImageDetailsScreenState extends State<ImageDetailsScreen> {
  String get _uid => AuthService.instance.currentUid;

  Future<void> _withMe(Future<void> Function(AppUser me) action) async {
    final me = await UserService.instance.getUser(_uid);
    if (me == null) {
      if (mounted) showNeoTip(context, 'PROFILE LINK LOST // RE-AUTHENTICATE');
      return;
    }
    await action(me);
  }

  String _formatFull(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final remaining = text.length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }

  Future<void> _toggleLike(Pin pin) async {
    try {
      await _withMe((me) async {
        final liked = await PinService.instance.toggleLike(
          pin: pin,
          uid: me.uid,
          actorName: me.name,
          actorUsername: me.username,
          actorAvatarUrl: me.avatarUrl,
        );
        if (mounted) {
          showNeoTip(context, liked ? 'LIKE REGISTERED' : 'LIKE REVOKED');
        }
      });
    } catch (_) {
      if (mounted) showNeoError(context, 'LIKE FAILED // RETRY IN A MOMENT');
    }
  }

  Future<void> _toggleFollow(Pin pin) async {
    if (pin.authorId == _uid) {
      showNeoTip(context, 'THIS IS YOUR OWN DROP // SELF-FOLLOW BLOCKED');
      return;
    }
    try {
      await _withMe((me) async {
        final following = await UserService.instance.toggleFollow(
          myUid: me.uid,
          myName: me.name,
          myUsername: me.username,
          myAvatarUrl: me.avatarUrl,
          targetUid: pin.authorId,
        );
        if (mounted) {
          showNeoTip(context, following ? 'FOLLOWING ${pin.authorUsername.toUpperCase()}' : 'UNFOLLOWED');
        }
      });
    } catch (_) {
      if (mounted) showNeoError(context, 'FOLLOW FAILED // RETRY IN A MOMENT');
    }
  }

  Future<void> _openSaveSheet(Pin pin) async {
    showNeoSheet<void>(
      context,
      title: 'DROP TO BOARD',
      child: _SaveToBoardSheet(pin: pin),
    );
  }

  void _openCommentSheet(Pin pin) {
    final controller = TextEditingController();
    showNeoSheet<void>(
      context,
      title: 'WRITE NOTE',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          neoTextField(
            controller: controller,
            hint: 'Transmit your note...',
            autofocus: true,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          neoPrimaryButton(
            label: 'TRANSMIT NOTE',
            onTap: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              await _withMe((me) async {
                await PinService.instance.addComment(
                  pin: pin,
                  uid: me.uid,
                  actorName: me.name,
                  actorUsername: me.username,
                  actorAvatarUrl: me.avatarUrl,
                  text: text,
                );
                if (mounted) showNeoTip(context, 'NOTE TRANSMITTED');
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Pin?>(
      stream: PinService.instance.streamPin(widget.pin.id),
      initialData: widget.pin,
      builder: (context, pinSnapshot) {
        final pin = pinSnapshot.data ?? widget.pin;
        return Scaffold(
          backgroundColor: const Color(0xFF0F1110),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F1110),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'PIN DETAIL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 16,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: 'https://pin-drop-b2e4d.web.app/pin/${pin.id}',
                    ),
                  );
                  if (context.mounted) {
                    showNeoTip(context, 'LINK COPIED TO CLIPBOARD');
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF161A18),
                  backgroundImage: pin.authorAvatarUrl.isEmpty
                      ? null
                      : NetworkImage(pin.authorAvatarUrl),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top URL & Sparks Tag Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A18),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'ARCHDIGEST.DESIGN',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.north_east,
                            color: Color(0xFFB6FF00),
                            size: 10,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF500),
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161A18),
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.upload_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Featured Image Container with Overlays
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A18),
                    border: Border.all(
                      color: const Color(0xFFB6FF00),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Image.network(
                        pin.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 380,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 380,
                            color: const Color(0xFF161A18),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFB6FF00),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 380,
                          color: const Color(0xFF161A18),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: const Color(0xFFFF0055),
                          child: const Text(
                            '⚡ STAFF SPARK #984',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: Colors.black,
                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Color(0xFFB6FF00),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '14 VIEWING LIVE',
                                style: TextStyle(
                                  color: Color(0xFFB6FF00),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Drop to Board Primary Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB6FF00),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _openSaveSheet(pin),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        size: 18,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'DROP TO BOARD',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Interaction Bar (Likes, Remix, SVG)
                StreamBuilder<bool>(
                  stream: PinService.instance.streamIsLiked(pin.id, _uid),
                  builder: (context, likeSnapshot) {
                    final isLiked = likeSnapshot.data ?? false;
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleLike(pin),
                            child: _buildActionChip(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              _formatFull(pin.likesCount),
                              iconColor: isLiked
                                  ? const Color(0xFFFF0055)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => showNeoTip(
                              context,
                              'REMIX MODULE LOCKED // COMING SOON',
                            ),
                            child: _buildActionChip(
                              Icons.tune,
                              'REMIX',
                              iconColor: const Color(0xFFFFF500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                showNeoTip(context, 'EXPORT QUEUED // RAW SVG'),
                            child: _buildActionChip(
                              Icons.download,
                              'RAW SVG',
                              iconColor: const Color(0xFFB6FF00),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Pin Title & Description Meta
                const Row(
                  children: [
                    Text(
                      'ARCHIVE CODE: AG-409',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'RESTRICTED PRINT RUN',
                      style: TextStyle(
                        color: Color(0xFFFF0055),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  pin.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pin.description.isEmpty
                      ? 'NO DESCRIPTION LOGGED FOR THIS DROP.'
                      : pin.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Hashtag Pills
                if (pin.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < pin.tags.length; i++)
                        _buildTagChip(
                          '#${pin.tags[i]}',
                          _tagColorFor(i),
                          borderColor: _tagColorFor(i) == Colors.black
                              ? Colors.white54
                              : null,
                        ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Author Profile Card
                StreamBuilder<AppUser?>(
                  stream: UserService.instance.streamUser(pin.authorId),
                  builder: (context, authorSnapshot) {
                    final followers = authorSnapshot.data?.followersCount ?? 0;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A18),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF0F1110),
                            backgroundImage: pin.authorAvatarUrl.isEmpty
                                ? null
                                : NetworkImage(pin.authorAvatarUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pin.authorUsername.isEmpty
                                      ? pin.authorName
                                      : pin.authorUsername,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${formatCount(followers)} COLLECTORS',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<bool>(
                            stream: UserService.instance.streamIsFollowing(
                              _uid,
                              pin.authorId,
                            ),
                            builder: (context, followSnapshot) {
                              final isFollowing = followSnapshot.data ?? false;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFF500),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () => _toggleFollow(pin),
                                child: Text(
                                  isFollowing ? 'FOLLOWING' : 'FOLLOW',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Discourse / Comment Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'DISCOURSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: const Color(0xFF161A18),
                          child: Text(
                            '${pin.commentsCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _openCommentSheet(pin),
                      child: const Text(
                        'WRITE NOTE',
                        style: TextStyle(
                          color: Color(0xFFFF0055),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Comments stream
                StreamBuilder<List<Comment>>(
                  stream: PinService.instance.streamComments(pin.id),
                  builder: (context, commentSnapshot) {
                    final comments = commentSnapshot.data ?? const <Comment>[];
                    if (comments.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A18),
                          border: Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NO TRANSMISSIONS YET // BE THE FIRST TO WRITE',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final comment in comments)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildCommentCard(comment),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _tagColorFor(int index) {
    const palette = [
      Color(0xFFFFF500),
      Colors.black,
      Color(0xFFB6FF00),
      Color(0xFFFF0055),
    ];
    return palette[index % palette.length];
  }

  Widget _buildCommentCard(Comment comment) {
    final isPress = comment.authorId == 'studio_helvetica';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName.startsWith('@')
                            ? comment.authorName
                            : '@${comment.authorName}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (isPress) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        color: const Color(0xFFB6FF00),
                        child: const Text(
                          'VERIFIED PRESS',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                timeAgo(comment.createdAt),
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${comment.text}"',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, {Color iconColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, Color color, {Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor ?? Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == Colors.black ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Bottom sheet listing the operator's boards + NEW BOARD creation.
class _SaveToBoardSheet extends StatefulWidget {
  final Pin pin;

  const _SaveToBoardSheet({required this.pin});

  @override
  State<_SaveToBoardSheet> createState() => _SaveToBoardSheetState();
}

class _SaveToBoardSheetState extends State<_SaveToBoardSheet> {
  String get _uid => AuthService.instance.currentUid;

  Future<void> _save({
    required AppUser me,
    required String boardId,
    required String boardName,
  }) async {
    try {
      final saved = await PinService.instance.savePinToBoard(
        pin: widget.pin,
        uid: me.uid,
        boardId: boardId,
        boardName: boardName,
        actorName: me.name,
        actorUsername: me.username,
        actorAvatarUrl: me.avatarUrl,
      );
      if (!mounted) return;
      Navigator.pop(context);
      showNeoTip(
        context,
        saved ? 'DROPPED TO $boardName' : 'ALREADY ROUTED TO $boardName',
      );
    } catch (_) {
      if (mounted) showNeoError(context, 'BOARD SAVE FAILED // RETRY');
    }
  }

  Future<void> _createAndSave() async {
    final nameController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kNeoPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kNeoLime, width: 1.5),
        ),
        title: const Text(
          'START A BOARD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
        content: neoTextField(
          controller: nameController,
          hint: 'e.g. RISO // PRINT VAULT',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'CREATE',
              style: TextStyle(
                color: kNeoLime,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );

    final name = nameController.text.trim();
    nameController.dispose();
    if (created != true || name.isEmpty || !mounted) return;

    final me = await UserService.instance.ensureUserProfile();
    if (me == null || !mounted) return;
    final boardId = await BoardService.instance.createBoard(me.uid, name);
    if (!mounted) return;
    await _save(me: me, boardId: boardId, boardName: name.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _createAndSave,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: kNeoLime,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, color: Colors.black, size: 16),
                SizedBox(width: 10),
                Text(
                  'NEW BOARD // CREATE & SAVE',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Board>>(
          stream: BoardService.instance.streamBoards(_uid),
          builder: (context, snapshot) {
            final boards = snapshot.data ?? const <Board>[];
            if (boards.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'NO BOARDS YET // CREATE YOUR FIRST VAULT ABOVE',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final board in boards.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () async {
                        final me = await UserService.instance.getUser(_uid);
                        if (me == null || !mounted) return;
                        await _save(
                          me: me,
                          boardId: board.id,
                          boardName: board.name,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: kNeoBlack,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_outlined,
                              color: kNeoLime,
                              size: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                board.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            Text(
                              '${board.pinCount} PINS',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
