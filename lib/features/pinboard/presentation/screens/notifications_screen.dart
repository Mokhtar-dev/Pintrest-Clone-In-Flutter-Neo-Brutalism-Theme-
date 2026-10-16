import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/pin_service.dart';
import '../../domain/entities/app_notification.dart';
import '../widgets/neo_feedback.dart';
import 'image_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String get _uid => AuthService.instance.currentUid;

  Future<void> _markAllRead() async {
    await NotificationService.instance.markAllRead(_uid);
    if (mounted) showNeoTip(context, 'ALL SIGNALS MARKED AS READ');
  }

  Future<void> _openNotification(AppNotification item) async {
    await NotificationService.instance.markRead(_uid, item.id);
    if (item.pinId.isEmpty || !mounted) return;
    final pin = await PinService.instance.getPin(item.pinId);
    if (!mounted) return;
    if (pin == null) {
      showNeoTip(context, 'DROP NO LONGER EXISTS ON THE GRID');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailsScreen(pin: pin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Header Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: Color(0xFFB6FF00), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'LIVE FEED // NOTIFS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161A18),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'MARK ALL READ',
                    style: TextStyle(
                      color: Color(0xFFB6FF00),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Notifications List View
        Expanded(
          child: StreamBuilder<List<AppNotification>>(
            stream: NotificationService.instance.streamNotifications(_uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const NeoEmptyState(
                  title: 'SYNCING SIGNALS',
                  subtitle: 'SYSTEM MODULE INITIALIZING...',
                );
              }
              final notifications = snapshot.data ?? const <AppNotification>[];
              if (notifications.isEmpty) {
                return const NeoEmptyState(
                  icon: Icons.notifications_none,
                  title: 'NO SIGNALS RECEIVED YET',
                  subtitle: 'LIKES, SAVES, COMMENTS AND FOLLOWS LAND HERE',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  final isUnread = !item.read;
                  return GestureDetector(
                    onTap: () => _openNotification(item),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? const Color(0xFF161A18)
                            : const Color(0xFF0F1110),
                        border: Border.all(
                          color: isUnread
                              ? const Color(0xFFB6FF00)
                              : Colors.white12,
                          width: isUnread ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // Avatar with Action Badge
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF161A18),
                                backgroundImage: item.actorAvatarUrl.isEmpty
                                    ? null
                                    : NetworkImage(item.actorAvatarUrl),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: _getBadgeColor(item.type),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _getBadgeIcon(item.type),
                                    size: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Notification Body Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${item.handle} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFB6FF00),
                                        ),
                                      ),
                                      TextSpan(text: '${item.actionText} '),
                                      if (item.pinTitle.isNotEmpty)
                                        TextSpan(
                                          text: item.pinTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeAgo(item.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Unread Indicator Pulse
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF0055),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getBadgeColor(String type) {
    switch (type) {
      case 'LIKE':
        return const Color(0xFFFF0055);
      case 'SAVE':
        return const Color(0xFFFFF500);
      case 'FOLLOW':
        return const Color(0xFFB6FF00);
      case 'COMMENT':
        return const Color(0xFF00E5FF);
      default:
        return const Color(0xFFB6FF00);
    }
  }

  IconData _getBadgeIcon(String type) {
    switch (type) {
      case 'LIKE':
        return Icons.favorite;
      case 'SAVE':
        return Icons.bookmark;
      case 'FOLLOW':
        return Icons.person_add;
      case 'COMMENT':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }
}
