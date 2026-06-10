import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LoggingService _logger = LoggingService.instance;

  // Motivational duas and messages for notifications
  final List<String> _motivationalMessages = [
    // Dua-focused messages
    '🌙 "O Allah, help me revive Your Sunnah today!" 🤲',
    '✨ "May this Sunnah bring barakah to your day!" 🤍',
    '💫 "Every Sunnah you revive brings you closer to Jannah!" 🤍',
    '🌟 "Allah loves those who follow the Sunnah of His Messenger!" 🤲',
    '🌿 "Plant a seed of Sunnah today, reap rewards in the hereafter!" 🤍',
    '🕌 "The best among you are those who learn the Sunnah and teach it!" 🤲',
    '💖 "Each Sunnah is a step towards Allah\'s pleasure!" 🤍',
    '🌙 "O Allah, make following the Sunnah beloved to my heart!" 🤲',
    '✨ "The Prophet\'s Sunnah is a light on your path!" 🌟',
    '💫 "Every Sunnah you revive removes a sin!" 🤍',
    '🌹 "O Allah, bless me with the love of following Your Sunnah!" 🤲',
    '🌙 "May this Sunnah be a source of light for me on the Day of Judgment!" 🤍',
    '✨ "O Allah, make me among those who revive Your Sunnah!" 🤲',
    '💫 "Each Sunnah practiced is a treasure stored for the hereafter!" 🤍',
    '🌟 "Following the Sunnah brings peace to the heart!" 🤍',

    // Encouraging messages
    '🌟 Time to practice today\'s Sunnah! You\'ve got this! 💪',
    '✨ Ready to revive another beautiful Sunnah today? 🌿',
    '💫 Your consistency in following Sunnah is inspiring! 🤍',
    '🌙 May this Sunnah bring peace and barakah to your day! 🤲',
    '🌿 One step closer to Allah with each Sunnah you revive! 🌟',
    '💖 Keep going! Every Sunnah counts towards your reward! 💪',
    '✨ You\'re doing amazing! Continue reviving those Sunnahs! 🌟',
    '🌙 May Allah make following Sunnah easy for you! 🤲',
    '💫 Your dedication to the Sunnah is a blessing! 🤍',
    '🌟 Another day, another opportunity to earn rewards! 💪',
    '🌙 Your commitment to reviving Sunnah is beautiful! 🌿',
    '✨ Every Sunnah you practice is a victory over your nafs! 💪',
    '💫 May Allah accept all your Sunnah practices! 🤲',
    '🌟 You\'re building a beautiful record of good deeds! 🌿',
    '🌙 Keep reviving those forgotten Sunnahs! You\'re doing great! 💪',

    // Reward-focused messages
    '💫 "The Prophet (ﷺ) said: \'Whoever revives my Sunnah when my Ummah becomes corrupt will have the reward of a hundred martyrs.\'" 🤲',
    '✨ "Each Sunnah you revive removes a sin and raises your rank!" 🌟',
    '🌙 "Following the Sunnah is the best way to show love for the Prophet!" 🤍',
    '🌿 "Every Sunnah practiced is a light on your grave!" 🌟',
    '💖 "The reward of a Sunnah is never diminished!" 🤲',
    '💫 "Each Sunnah is a shield against the Fire!" 🌟',
    '✨ "Following the Sunnah brings tranquility to the heart!" 🤍',
    '🌙 "Every Sunnah you revive is a gift to your future self!" 🌿',

    // Short and sweet messages
    '✨ Time for today\'s Sunnah! 🌟',
    '💫 Ready to revive a Sunnah? 🤍',
    '🌙 Practice today\'s Sunnah! 🌿',
    '🌟 Revive a forgotten Sunnah! 💪',
    '✨ Follow the Sunnah today! 🤲',
    '💫 Time to earn rewards! 🌟',
    '🌙 Practice with love! 🤍',
    '🌿 Revive with sincerity! 💪',
  ];

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for notifications
    await _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      // Request notification permission
      final status = await Permission.notification.request();
      _logger.info('Notification permission status: $status');

      if (status != PermissionStatus.granted) {
        _logger.warning('Notification permission not granted: $status');
      }
    } catch (e, stackTrace) {
      _logger.error('Error requesting notification permissions', e, stackTrace);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to app
    _logger.info('Notification tapped', {
      'payload': response.payload,
      'actionId': response.actionId,
      'input': response.input,
    });
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final permissionStatus = await Permission.notification.status;
      return permissionStatus == PermissionStatus.granted;
    } catch (e) {
      _logger.error('Error checking notification permission status', e);
      return false;
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String? customMessage,
  }) async {
    try {
      // Check if notifications are enabled
      final notificationsEnabled = await areNotificationsEnabled();
      if (!notificationsEnabled) {
        _logger
            .warning('Notifications are not enabled. Requesting permission...');
        await _requestNotificationPermissions();
      }

      // Cancel existing notifications
      await _notifications.cancelAll();

      // Get a random motivational message if no custom message is provided
      final message = customMessage ?? _getRandomMotivationalMessage();

      // Create vibration pattern
      final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

      // Log scheduling information
      _logger.info('Scheduling daily reminder', {
        'hour': hour,
        'minute': minute,
        'message': message,
      });

      // For Android 12+, we need to handle exact alarms properly
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexact;

      try {
        // Try to use exact scheduling if possible
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      } catch (e) {
        // Fall back to inexact scheduling if exact is not available
        _logger.info('Falling back to inexact scheduling: $e');
        scheduleMode = AndroidScheduleMode.inexact;
      }

      // Schedule new daily notification with enhanced design
      await _notifications.zonedSchedule(
        0, // Unique ID
        'Revive - Daily Sunnah Reminder 🌟',
        message,
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_sunnah_reminder',
            'Daily Sunnah Reminder',
            channelDescription: 'Daily reminders to practice Sunnah',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            // Enhanced notification appearance
            styleInformation: BigTextStyleInformation(
              'Continue your journey of reviving forgotten Sunnahs. Each practice brings you closer to Allah and earns you rewards in this life and the hereafter.',
              contentTitle: 'Revive - Daily Sunnah Reminder 🌟',
              summaryText: 'Revive App',
            ),
            color: const Color(0xFF2E7D32), // Islamic green color
            playSound: true,
            enableVibration: true,
            vibrationPattern: vibrationPattern,
            category: AndroidNotificationCategory.reminder,
            // Additional visual enhancements
            visibility: NotificationVisibility.public,
            onlyAlertOnce: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: '🌟 Daily Sunnah Reminder',
            // iOS specific enhancements
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      _logger.info('Daily reminder scheduled successfully');

      // Verify that the notification was scheduled
      try {
        final pendingNotifications =
            await _notifications.pendingNotificationRequests();
        _logger.info(
            'Pending notifications after scheduling: ${pendingNotifications.length}');
        for (var notification in pendingNotifications) {
          _logger.info(
              'Scheduled notification: ID=${notification.id}, Title=${notification.title}');
        }
      } catch (e) {
        _logger.error('Error checking pending notifications', e);
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to schedule daily reminder', e, stackTrace);
      rethrow;
    }
  }

  // Get a random motivational message
  String _getRandomMotivationalMessage() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    return _motivationalMessages[random];
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<Map<String, int>?> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour');
    final minute = prefs.getInt('reminder_minute');

    if (hour != null && minute != null) {
      return {'hour': hour, 'minute': minute};
    }
    return null;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification',
          'Instant Notifications',
          channelDescription: 'Instant notifications for app events',
          importance: Importance.low,
          priority: Priority.low,
        ),
      ),
      payload: payload,
    );
  }

  // Show a test notification with the cute design
  Future<void> showTestNotification() async {
    // Create vibration pattern
    final vibrationPattern = Int64List.fromList([0, 500, 250, 500]);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Revive - Test Notification 🌟',
      _getRandomMotivationalMessage(),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification',
          'Test Notifications',
          channelDescription: 'Test notification to preview design',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            'This is a preview of your daily Sunnah reminder notifications. Each notification will feature beautiful duas and motivational messages to encourage you to revive forgotten Sunnahs!',
            contentTitle: 'Revive - Test Notification 🌟',
            summaryText: 'Revive App',
          ),
          color: const Color(0xFF2E7D32),
          playSound: true,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle: '🌟 Test Notification',
          badgeNumber: 1,
        ),
      ),
    );
  }

  // Get pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      _logger
          .info('Pending notifications count: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        _logger.info(
            'Pending notification: ID=${notification.id}, Title=${notification.title}');
      }
      return pendingNotifications;
    } catch (e, stackTrace) {
      _logger.error('Error getting pending notifications', e, stackTrace);
      return [];
    }
  }
}
