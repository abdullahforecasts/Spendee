import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _allNotifications = [
    {
      'title': 'Payment Received! 🎉',
      'message': 'Ali Maqsood just sent you Rs. 5,000 for the Murree Trip. The amount has been added to your wallet.',
      'time': '2 hours ago',
      'read': false,
      'expanded': false,
      'type': 'payment'
    },
    {
      'title': 'Group Invitation',
      'message': 'Abdullah invited you to join "Weekend Trip" group. Tap to view details and accept the invitation.',
      'time': '1 day ago',
      'read': false,
      'expanded': false,
      'type': 'invitation'
    },
    {
      'title': 'Payment Reminder ⚠️',
      'message': 'Reminder: Your payment of Rs. 2,000 for "Car Pooling" is due tomorrow. Please make the payment to avoid late fees.',
      'time': '2 days ago',
      'read': true,
      'expanded': false,
      'type': 'reminder'
    },
    {
      'title': 'Room Created Successfully',
      'message': 'Your room "Office Friends" has been created successfully. You can now add members and start creating groups.',
      'time': '3 days ago',
      'read': true,
      'expanded': false,
      'type': 'success'
    },
    {
      'title': 'Friend Request',
      'message': 'Anas Faisal wants to connect with you on Spendee. Accept the request to start sharing expenses.',
      'time': '1 week ago',
      'read': true,
      'expanded': false,
      'type': 'friend'
    },
    {
      'title': 'Weekly Summary',
      'message': 'You spent Rs. 12,500 across 3 groups this week. Your most active group was "Murree Trip".',
      'time': '1 week ago',
      'read': true,
      'expanded': false,
      'type': 'summary'
    },
    {
      'title': 'Security Alert',
      'message': 'A new device logged into your account. If this wasn\'t you, please change your password immediately.',
      'time': '2 weeks ago',
      'read': true,
      'expanded': false,
      'type': 'security'
    },
    {
      'title': 'App Update Available',
      'message': 'New version 2.1.0 is available with better performance and new features. Update now!',
      'time': '2 weeks ago',
      'read': true,
      'expanded': false,
      'type': 'update'
    },
    {
      'title': 'Payment Failed',
      'message': 'Your payment of Rs. 3,000 to Abdullah failed due to insufficient funds. Please try again.',
      'time': '3 weeks ago',
      'read': true,
      'expanded': false,
      'type': 'failed'
    },
    {
      'title': 'Welcome to Spendee!',
      'message': 'Thank you for joining Spendee! Start by creating your first group or joining existing ones with friends.',
      'time': '1 month ago',
      'read': true,
      'expanded': false,
      'type': 'welcome'
    },
    {
      'title': 'Bonus Credit Added',
      'message': 'As a welcome bonus, we\'ve added Rs. 500 to your wallet. Use it within 30 days.',
      'time': '1 month ago',
      'read': true,
      'expanded': false,
      'type': 'bonus'
    },
  ];

  final int _notificationLimit = 8; // Show only latest 8 notifications

  List<Map<String, dynamic>> get _displayedNotifications {
    return _allNotifications.take(_notificationLimit).toList();
  }

  int get _unreadCount {
    return _allNotifications.where((n) => !n['read']).length;
  }

  void _toggleNotificationExpansion(int index) {
    setState(() {
      // Toggle expansion for the clicked notification
      _displayedNotifications[index]['expanded'] =
      !_displayedNotifications[index]['expanded'];

      // Mark as read when expanded
      if (_displayedNotifications[index]['expanded'] &&
          !_displayedNotifications[index]['read']) {
        _displayedNotifications[index]['read'] = true;

        // Also update in the main list to maintain state
        final actualIndex = _allNotifications.indexOf(_displayedNotifications[index]);
        if (actualIndex != -1) {
          _allNotifications[actualIndex]['read'] = true;
        }
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification['read'] = true;
        notification['expanded'] = false;
      }
    });
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'payment':
        return Colors.green;
      case 'invitation':
        return Colors.blue;
      case 'reminder':
        return Colors.orange;
      case 'friend':
        return Colors.purple;
      case 'security':
        return Colors.red;
      case 'failed':
        return Colors.red;
      default:
        return const Color(0xFF00D09E);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'invitation':
        return Icons.group_add;
      case 'reminder':
        return Icons.schedule;
      case 'friend':
        return Icons.person_add;
      case 'security':
        return Icons.security;
      case 'failed':
        return Icons.error;
      case 'success':
        return Icons.check_circle;
      case 'summary':
        return Icons.analytics;
      case 'update':
        return Icons.system_update;
      case 'welcome':
        return Icons.celebration;
      case 'bonus':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Spendee",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_unreadCount > 0)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  _markAllAsRead();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'mark_all_read',
                  child: Text('Mark all as read ($_unreadCount)'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Notifications",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (_unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D09E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$_unreadCount new",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Showing latest $_notificationLimit of ${_allNotifications.length} notifications",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: _displayedNotifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                      itemCount: _displayedNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _displayedNotifications[index];
                        return _buildNotificationCard(notification, index);
                      },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "No notifications",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            "Your notifications will appear here",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['read'] ?? false;
    final isExpanded = notification['expanded'] ?? false;
    final typeColor = _getTypeColor(notification['type']);
    final typeIcon = _getTypeIcon(notification['type']);

    return GestureDetector(
      onTap: () => _toggleNotificationExpansion(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.grey.shade50 : const Color(0xFFE6F8F0),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isRead ? Colors.transparent : typeColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: typeColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(isRead ? 0.1 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeIcon,
                    color: isRead ? Colors.grey : typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isRead ? Colors.black54 : Colors.black,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isExpanded)
                        Text(
                          notification['message'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isRead ? Colors.grey : Colors.black54,
                          ),
                        )
                      else
                        Text(
                          "...",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isRead ? Colors.grey : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}