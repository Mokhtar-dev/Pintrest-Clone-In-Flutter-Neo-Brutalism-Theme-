import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/pin_service.dart';
import '../../../../services/user_service.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/pin.dart';
import '../widgets/neo_feedback.dart';
import '../widgets/pin_card.dart';
import 'explore_screen.dart';
import 'image_details_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0; // 0: Home, 1: Explore, 2: Notifications, 3: Profile
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'ALL',
    'ACID GRAPHICS',
    '3D CLAY',
    'RAW TYPOGRAPHY',
  ];

  String get _uid => AuthService.instance.currentUid;

  @override
  void initState() {
    super.initState();
    // Populate the showcase drops once on an empty project so the feed keeps
    // the original design look. Safe no-op when pins already exist.
    PinService.instance.seedSamplePinsIfEmpty();
    // Self-heal a missing profile document (e.g. account created in the
    // Firebase console) so every screen has operator data to render.
    _healProfile();
  }

  Future<void> _healProfile() async {
    try {
      await UserService.instance.ensureUserProfile();
    } catch (_) {
      // Silent - the profile is re-checked on every action anyway.
    }
  }

  // Fetches the latest profile of the signed in operator before an action so
  // notifications always carry fresh name/avatar data.
  Future<void> _withMe(Future<void> Function(AppUser me) action) async {
    final me = await UserService.instance.ensureUserProfile();
    if (me == null) {
      if (mounted) showNeoTip(context, 'PROFILE LINK LOST // RE-AUTHENTICATE');
      return;
    }
    await action(me);
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
        if (mounted && liked) {
          showNeoTip(context, 'LIKE REGISTERED // ${pin.title}');
        }
      });
    } catch (_) {
      if (mounted) showNeoError(context, 'LIKE FAILED // RETRY IN A MOMENT');
    }
  }

  Future<void> _savePin(Pin pin) async {
    try {
      await _withMe((me) async {
        final saved = await PinService.instance.savePinToSaved(
          pin: pin,
          uid: me.uid,
          actorName: me.name,
          actorUsername: me.username,
          actorAvatarUrl: me.avatarUrl,
        );
        if (mounted) {
          showNeoTip(
            context,
            saved ? 'DROPPED TO SAVED VAULT' : 'ALREADY IN SAVED VAULT',
          );
        }
      });
    } catch (_) {
      if (mounted) showNeoError(context, 'SAVE FAILED // RETRY IN A MOMENT');
    }
  }

  void _showPinOptions(Pin pin) {
    final isOwner = pin.authorId == _uid;
    showNeoSheet<void>(
      context,
      title: 'DROP CONTROLS // ${pin.title}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetAction(
            icon: Icons.link,
            label: 'COPY LINK',
            onTap: () async {
              Navigator.pop(context);
              await Clipboard.setData(
                ClipboardData(
                  text: 'https://pin-drop-b2e4d.web.app/pin/${pin.id}',
                ),
              );
              if (mounted) showNeoTip(context, 'LINK COPIED TO CLIPBOARD');
            },
          ),
          const SizedBox(height: 8),
          if (isOwner)
            _sheetAction(
              icon: Icons.delete_outline,
              label: 'DELETE DROP',
              tint: kNeoRed,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await _confirmDelete(pin);
                if (confirm) {
                  await PinService.instance.deletePin(pin);
                  if (mounted) showNeoTip(context, 'DROP PURGED FROM GRID');
                }
              },
            )
          else
            _sheetAction(
              icon: Icons.flag_outlined,
              label: 'REPORT DROP',
              tint: kNeoYellow,
              onTap: () {
                Navigator.pop(context);
                showNeoTip(context, 'REPORT DISPATCHED TO CONTROL');
              },
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Pin pin) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kNeoPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: kNeoRed, width: 1.5),
        ),
        title: const Text(
          'PURGE DROP?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 1.2,
          ),
        ),
        content: Text(
          '${pin.title} WILL BE REMOVED FROM THE GRID PERMANENTLY.',
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
    return result ?? false;
  }

  Widget _sheetAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color tint = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kNeoBlack,
          border: Border.all(color: Colors.white24, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 16),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: tint,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List of page bodies mapping directly to index [0, 1, 2, 3]
    final List<Widget> pages = [
      _buildHomeFeedView(), // Index 0: Home / Feed
      const ExploreScreen(), // Index 1: Explore / Search
      const NotificationsScreen(), // Index 2: Notifications
      ProfileScreen(
        // Index 3: Profile Screen (bell icon jumps to the notifications tab)
        onOpenNotifications: () => setState(() => _currentNavIndex = 2),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1110),
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: pages,
        ),
      ),

      // Cyberpunk Bottom Navigation Bar with Automatic Screen Switching
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1110),
          border: Border(top: BorderSide(color: Colors.white12, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'HOME', 0),
            _buildNavItem(Icons.explore_outlined, 'EXPLORE', 1),
            // Center High-Impact Add Button - opens the URL uplink directly.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB6FF00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 22),
              ),
            ),
            _buildNavItem(Icons.notifications_outlined, 'NOTIFS', 2),
            _buildNavItem(Icons.person_outline, 'PROFILE', 3),
          ],
        ),
      ),
    );
  }

  // Extracted Home Feed Layout
  Widget _buildHomeFeedView() {
    return Column(
      children: [
        // 1. Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  const SizedBox(width: 10),
                  const Text(
                    'PIN / DROP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
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
                      icon: StreamBuilder<int>(
                        stream: NotificationService.instance
                            .streamUnreadCount(_uid),
                        builder: (context, snapshot) {
                          final unread = snapshot.data ?? 0;
                          return Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              if (unread > 0)
                                const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Color(0xFFFF0055),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      onPressed: () =>
                          setState(() => _currentNavIndex = 2), // Swaps to Notifications tab
                    ),
                  ),
                  const SizedBox(width: 10),
                  StreamBuilder<AppUser?>(
                    stream: UserService.instance.streamUser(_uid),
                    builder: (context, snapshot) {
                      final avatarUrl = snapshot.data?.avatarUrl ?? '';
                      return GestureDetector(
                        onTap: () => setState(
                            () => _currentNavIndex = 3), // Swaps to Profile tab
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB6FF00),
                              width: 2,
                            ),
                            color: const Color(0xFF161A18),
                            image: avatarUrl.isEmpty
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Filter Pills Horizontal List
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFB6FF00)
                        : const Color(0xFF161A18),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.white24,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // 3. Cyber Stream Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF161A18),
            border: Border.all(color: const Color(0xFFFFF500), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFFFF0055), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'LIVE STREAM // 14.8K CURATORS A...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF500),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Text(
                  'DROP #088',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Staggered Masonry Grid Feed (live Firestore stream)
        Expanded(
          child: StreamBuilder<List<Pin>>(
            stream: PinService.instance.streamPins(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const NeoEmptyState(
                  title: 'PULLING FRESH DROPS',
                  subtitle: 'SYSTEM MODULE INITIALIZING...',
                );
              }
              if (snapshot.hasError) {
                return const NeoEmptyState(
                  icon: Icons.wifi_off,
                  title: 'STREAM OFFLINE',
                  subtitle: 'CHECK NETWORK UPLINK AND RETRY',
                );
              }
              final allPins = snapshot.data ?? const <Pin>[];
              final pins = _selectedCategoryIndex == 0
                  ? allPins
                  : allPins
                      .where((pin) =>
                          pin.category ==
                          _categories[_selectedCategoryIndex])
                      .toList();

              if (pins.isEmpty) {
                return NeoEmptyState(
                  icon: Icons.grid_view_rounded,
                  title: 'NO DROPS IN THIS CHANNEL',
                  subtitle: 'TAP + TO UPLOAD THE FIRST DROP',
                );
              }

              return RefreshIndicator(
                color: const Color(0xFFB6FF00),
                backgroundColor: const Color(0xFF161A18),
                onRefresh: () =>
                    Future<void>.delayed(const Duration(milliseconds: 600)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: pins.length,
                    itemBuilder: (context, index) {
                      final pin = pins[index];
                      return _LivePinCard(
                        pin: pin,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ImageDetailsScreen(pin: pin),
                            ),
                          );
                        },
                        onSave: () => _savePin(pin),
                        onLike: () => _toggleLike(pin),
                        onMore: () => _showPinOptions(pin),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Pulling Fresh Drops Bar
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF161A18),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, color: const Color(0xFFB6FF00)),
              const SizedBox(width: 8),
              const Text(
                'PULLING FRESH DROPS...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFB6FF00) : Colors.white38,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFB6FF00) : Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Feed card wired to the live like/saved state of the signed-in operator, so
/// the heart and bookmark fill (and unfill) in real time on the home feed.
class _LivePinCard extends StatelessWidget {
  final Pin pin;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onLike;
  final VoidCallback onMore;

  const _LivePinCard({
    required this.pin,
    required this.onTap,
    required this.onSave,
    required this.onLike,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUid;
    return StreamBuilder<bool>(
      stream: PinService.instance.streamIsLiked(pin.id, uid),
      initialData: false,
      builder: (context, likeSnapshot) {
        return StreamBuilder<bool>(
          stream: PinService.instance.streamIsSaved(uid, pin.id),
          initialData: false,
          builder: (context, saveSnapshot) {
            return PinCard(
              pin: pin,
              onTap: onTap,
              onSave: onSave,
              onLike: onLike,
              onMore: onMore,
              isLiked: likeSnapshot.data ?? false,
              isSaved: saveSnapshot.data ?? false,
            );
          },
        );
      },
    );
  }
}
