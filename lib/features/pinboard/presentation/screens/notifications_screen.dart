import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock notifications array (when Firebase is connected, this will pull real-time Firestore updates)
  final List<Map<String, dynamic>> _notifications = [
    {
      'username': '@acid_vault',
      'action': 'liked your drop',
      'target': 'SYSTEM MATRIX 04',
      'time': '2M AGO',
      'type': 'LIKE', // LIKE, SAVE, COMMENT, FOLLOW
      'avatar': 'https://i.pravatar.cc/100?img=33',
      'isUnread': true,
    },
    {
      'username': '@risolab',
      'action': 'saved your drop to board',
      'target': 'RISO // PRINT VAULT',
      'time': '15M AGO',
      'type': 'SAVE',
      'avatar': 'https://i.pravatar.cc/100?img=12',
      'isUnread': true,
    },
    {
      'username': '@studio_ke_',
      'action': 'started following your stream',
      'target': '',
      'time': '1H AGO',
      'type': 'FOLLOW',
      'avatar': 'https://i.pravatar.cc/100?img=47',
      'isUnread': false,
    },
    {
      'username': '@archidrop',
      'action': 'commented: "Clean composition!" on',
      'target': 'MONOLITH BUNKER 9',
      'time': '3H AGO',
      'type': 'COMMENT',
      'avatar': 'https://i.pravatar.cc/100?img=60',
      'isUnread': false,
    },
  ];

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
          ),
        ),

        // 2. Notifications List View
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final item = _notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item['isUnread'] ? const Color(0xFF161A18) : const Color(0xFF0F1110),
                  border: Border.all(
                    color: item['isUnread'] ? const Color(0xFFB6FF00) : Colors.white12,
                    width: item['isUnread'] ? 1.5 : 1.0,
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
                          backgroundImage: NetworkImage(item['avatar']),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(item['type']),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Icon(
                              _getBadgeIcon(item['type']),
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
                              style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3),
                              children: [
                                TextSpan(
                                  text: '${item['username']} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB6FF00),
                                  ),
                                ),
                                TextSpan(text: '${item['action']} '),
                                if (item['target'].isNotEmpty)
                                  TextSpan(
                                    text: item['target'],
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
                            item['time'],
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
                    if (item['isUnread'])
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