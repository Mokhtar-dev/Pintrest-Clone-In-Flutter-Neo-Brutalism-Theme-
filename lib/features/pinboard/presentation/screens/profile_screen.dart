import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/board_service.dart';
import '../../../../services/pin_service.dart';
import '../../../../services/user_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/pin.dart';
import '../widgets/neo_feedback.dart';
import '../widgets/pin_card.dart';
import 'board_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'image_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  /// Lets the parent switch to the notifications tab from the header bell.
  final VoidCallback? onOpenNotifications;

  const ProfileScreen({super.key, this.onOpenNotifications});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0: Boards, 1: Saved

  String get _uid => AuthService.instance.currentUid;

  Future<void> _createBoard() async {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NAME YOUR NEW MOODBOARD OR SECRET VAULT.',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
            const SizedBox(height: 12),
            neoTextField(
              controller: nameController,
              hint: 'e.g. RISO // PRINT VAULT',
              autofocus: true,
            ),
          ],
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
    if (created != true || name.isEmpty) return;

    await BoardService.instance.createBoard(_uid, name);
    if (mounted) showNeoTip(context, 'BOARD INITIALIZED // $name');
  }

  Future<void> _confirmDeleteBoard(Board board) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kNeoPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kNeoRed, width: 1.5),
        ),
        title: const Text(
          'PURGE BOARD?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
        content: Text(
          '${board.name} WILL BE DELETED. SAVED DROPS REMAIN IN YOUR VAULT.',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
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
              'DELETE',
              style: TextStyle(
                color: kNeoRed,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
    if (result == true) {
      await BoardService.instance.deleteBoard(_uid, board.id);
      if (mounted) showNeoTip(context, 'BOARD PURGED');
    }
  }

  void _showMoreOptions() {
    showNeoSheet<void>(
      context,
      title: 'OPERATOR CONTROLS',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await Clipboard.setData(
                ClipboardData(text: 'https://pin-drop-b2e4d.web.app/@$_uid'),
              );
              if (mounted) showNeoTip(context, 'PROFILE LINK COPIED');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: kNeoBlack,
                border: Border.all(color: Colors.white24, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.link, color: Colors.white, size: 16),
                  SizedBox(width: 10),
                  Text(
                    'COPY PROFILE LINK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              // AuthGate switches back to LoginScreen automatically.
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: kNeoBlack,
                border: Border.all(color: kNeoRed, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: kNeoRed, size: 16),
                  SizedBox(width: 10),
                  Text(
                    'TERMINATE SESSION // LOG OUT',
                    style: TextStyle(
                      color: kNeoRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSavedPin(Pin pin) async {
    final fresh = await PinService.instance.getPin(pin.id);
    if (!mounted) return;
    if (fresh == null) {
      showNeoTip(context, 'DROP NO LONGER EXISTS ON THE GRID');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailsScreen(pin: fresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: UserService.instance.streamUser(_uid),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        return Column(
          children: [
            // 1. Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A18),
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xFFB6FF00),
                      size: 16,
                    ),
                  ),
                  const Text(
                    'PIN / DROP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A18),
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: widget.onOpenNotifications,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFB6FF00),
                            width: 2,
                          ),
                          color: const Color(0xFF161A18),
                          image: (user?.avatarUrl.isNotEmpty ?? false)
                              ? DecorationImage(
                                  image: NetworkImage(user!.avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content Scrollable Area
            Expanded(
              child: StreamBuilder<List<Pin>>(
                stream: PinService.instance.streamSavedPins(_uid),
                builder: (context, savedSnapshot) {
                  final savedPins = savedSnapshot.data ?? const <Pin>[];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // 2. User Profile Header Card
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white24,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFF161A18),
                                    image: (user?.avatarUrl.isNotEmpty ??
                                            false)
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(user!.avatarUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: (user?.avatarUrl.isNotEmpty ?? false)
                                      ? null
                                      : const Icon(
                                          Icons.person_outline_rounded,
                                          color: Colors.white38,
                                          size: 36,
                                        ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    color: const Color(0xFFFFF500),
                                    child: const Text(
                                      '★ ONLINE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (user?.name ?? 'OPERATOR')
                                              .toUpperCase(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFFB6FF00),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${(user?.username ?? 'unknown').toUpperCase()}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFB6FF00),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    (user?.bio.isNotEmpty ?? false)
                                        ? user!.bio
                                        : 'No curator story logged yet. Tap edit profile to add one...',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3. Stats Metric Boxes Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                formatCount(user?.pinsCount ?? 0),
                                'PINS',
                                const Color(0xFFFFF500),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatBox(
                                formatCount(
                                  user?.boardsCount ?? 0,
                                ),
                                'BOARDS',
                                const Color(0xFFB6FF00),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatBox(
                                formatCount(user?.savesReceived ?? 0),
                                'SAVES',
                                const Color(0xFFFF0055),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 4. Action Buttons (Edit Profile, Share, More)
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF161A18),
                                  side: const BorderSide(
                                    color: Colors.white24,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.tune,
                                  color: Color(0xFFB6FF00),
                                  size: 16,
                                ),
                                label: const Text(
                                  'EDIT PROFILE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161A18),
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.share_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            'https://pin-drop-b2e4d.web.app/@$_uid',
                                      ),
                                    );
                                    if (context.mounted) {
                                      showNeoTip(
                                        context,
                                        'PROFILE LINK COPIED',
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF161A18),
                                  border: Border.all(
                                    color: Colors.white24,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: _showMoreOptions,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 5. Boards / Saved Tabs Selector
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0
                                        ? const Color(0xFF161A18)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _selectedTab == 0
                                          ? const Color(0xFFB6FF00)
                                          : Colors.white24,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'BOARDS (${user?.boardsCount ?? 0})',
                                      style: TextStyle(
                                        color: _selectedTab == 0
                                            ? Colors.white
                                            : Colors.white54,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1
                                        ? const Color(0xFF161A18)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _selectedTab == 1
                                          ? const Color(0xFFB6FF00)
                                          : Colors.white24,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'SAVED (${savedPins.length})',
                                      style: TextStyle(
                                        color: _selectedTab == 1
                                            ? Colors.white
                                            : Colors.white54,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 6. Tab Content
                        if (_selectedTab == 0)
                          _buildBoardsGrid()
                        else
                          _buildSavedGrid(savedPins),
                        const SizedBox(height: 16),

                        // 7. Start a Board Card
                        GestureDetector(
                          onTap: _createBoard,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161A18),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB6FF00),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'START A BOARD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'NEW MOODBOARD OR SECRET VAULT',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border:
                                        Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 8. Pro Tip Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF500),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'PRO TIP: LONG PRESS ANY BOARD TO PURGE IT FROM THE VAULT',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoardsGrid() {
    return StreamBuilder<List<Board>>(
      stream: BoardService.instance.streamBoards(_uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFB6FF00),
                ),
              ),
            ),
          );
        }
        final boards = snapshot.data ?? const <Board>[];
        if (boards.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1110),
              border: Border.all(color: Colors.white12, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.grid_view_rounded, color: Colors.white24, size: 32),
                SizedBox(height: 8),
                Text(
                  'NO BOARDS INITIALIZED',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'START ONE BELOW TO ORGANIZE YOUR DROPS',
                  style: TextStyle(color: Colors.white24, fontSize: 9),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: boards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final board = boards[index];
            final hasPins = board.pinCount > 0;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardDetailScreen(board: board),
                  ),
                );
              },
              onLongPress: () => _confirmDeleteBoard(board),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161A18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white24,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          if (board.coverImageUrl.isEmpty)
                            Container(
                              color: const Color(0xFF0F1110),
                              child: const Center(
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFFB6FF00),
                                  size: 28,
                                ),
                              ),
                            )
                          else
                            Image.network(
                              board.coverImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: hasPins
                                    ? const Color(0xFFB6FF00)
                                    : const Color(0xFF00E5FF),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                hasPins ? 'UPDATED' : 'EMPTY',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            board.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${board.pinCount} PINS',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedGrid(List<Pin> savedPins) {
    if (savedPins.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1110),
          border: Border.all(color: Colors.white12, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.bookmark_border, color: Colors.white24, size: 32),
            SizedBox(height: 8),
            Text(
              'SAVED VAULT EMPTY',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'TAP SAVE ON ANY DROP TO STOCK THE VAULT',
              style: TextStyle(color: Colors.white24, fontSize: 9),
            ),
          ],
        ),
      );
    }
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: savedPins.length,
      itemBuilder: (context, index) {
        final pin = savedPins[index];
        return PinCard(
          pin: pin,
          isSaved: true,
          onTap: () => _openSavedPin(pin),
        );
      },
    );
  }

  Widget _buildStatBox(String count, String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A18),
        border: Border.all(color: accentColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
