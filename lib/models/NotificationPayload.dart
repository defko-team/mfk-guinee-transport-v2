import '../components/NotificationStringBuilder.dart';

class NotificationPayload {
  final String title;
  final String body;
  final Map<String, String> data;
  final NotificationPriority priority;
  final NotificationCategory category;

  const NotificationPayload({
    required this.title,
    required this.body,
    this.data = const {},
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.general,
  });

  /// Convert to FCM payload format
  Map<String, dynamic> toFcmPayload() {
    return {
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        ...data,
        'priority': priority.name,
        'category': category.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      'android': {
        'priority': _getAndroidPriority(),
        'notification': {
          'channel_id': _getChannelId(),
          'sound': 'default',
        },
      },
      'apns': {
        'payload': {
          'aps': {
            'sound': 'default',
            'badge': 1,
          },
        },
      },
    };
  }

  String _getChannelId() {
    switch (category) {
      case NotificationCategory.travel:
        return 'travel_updates';
      case NotificationCategory.reminder:
        return 'travel_reminders';
      case NotificationCategory.alert:
        return 'important_alerts';
      case NotificationCategory.realtime:
        return 'realtime_updates';
      case NotificationCategory.completion:
        return 'trip_completion';
      case NotificationCategory.update:
        return 'general_updates';
      case NotificationCategory.general:
        return 'general';
    }
  }
  String _getAndroidPriority() {
    switch (priority) {
      case NotificationPriority.urgent:
        return 'high';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.normal:
        return 'default';
      case NotificationPriority.low:
        return 'low';
    }
  }

}

