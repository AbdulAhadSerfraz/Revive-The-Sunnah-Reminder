import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/core/di/service_locator.dart';
import 'package:revive_sunnah_reminder/services/notification_service.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay? _reminderTime;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationService = serviceLocator.get<NotificationService>();
      final reminderTime = await notificationService.getReminderTime();

      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        if (reminderTime != null) {
          _reminderTime = TimeOfDay(
              hour: reminderTime['hour']!, minute: reminderTime['minute']!);
        } else {
          _reminderTime =
              const TimeOfDay(hour: 6, minute: 0); // Default to 6:00 AM
        }
        _isLoading = false;
      });

      // If notifications are enabled, schedule the reminder
      if (_notificationsEnabled && _reminderTime != null) {
        try {
          await notificationService.scheduleDailyReminder(
            hour: _reminderTime!.hour,
            minute: _reminderTime!.minute,
          );
        } catch (e) {
          // Log the error but don't crash the app
          final logger = serviceLocator.get<LoggingService>();
          logger.error('Failed to schedule notification on load', e);
        }
      }
    } catch (e) {
      // Handle any errors during loading
      final logger = serviceLocator.get<LoggingService>();
      logger.error('Failed to load settings', e);

      // Set default values
      setState(() {
        _notificationsEnabled = true;
        _reminderTime = const TimeOfDay(hour: 6, minute: 0);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReminderTime(TimeOfDay time) async {
    setState(() {
      _reminderTime = time;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);

    if (_notificationsEnabled) {
      try {
        final notificationService = serviceLocator.get<NotificationService>();
        await notificationService.scheduleDailyReminder(
          hour: time.hour,
          minute: time.minute,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Notification time updated successfully! Reminder scheduled.'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        // Handle error and show user feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to update notification time: ${e.toString()}. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);

    if (value && _reminderTime != null) {
      try {
        final notificationService = serviceLocator.get<NotificationService>();
        // Check if notifications are enabled
        final notificationsEnabled =
            await notificationService.areNotificationsEnabled();
        if (!notificationsEnabled) {
          // Show a message to the user that they need to enable notifications
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please enable notifications in your device settings for reminders to work.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        await notificationService.scheduleDailyReminder(
          hour: _reminderTime!.hour,
          minute: _reminderTime!.minute,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Daily reminder scheduled successfully!'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } catch (e) {
        // Handle error and show user feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to schedule notification: ${e.toString()}. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Revert the toggle if scheduling failed
        setState(() {
          _notificationsEnabled = false;
        });
        await prefs.setBool('notifications_enabled', false);
      }
    } else {
      final notificationService = serviceLocator.get<NotificationService>();
      await notificationService.cancelAllNotifications();

      if (mounted && !value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily reminders disabled.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading settings...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notifications Section
                  _buildModernSectionCard(
                    title: 'Notifications',
                    icon: Icons.notifications_rounded,
                    iconColor: Colors.blue[600] ?? Colors.blue,
                    children: [
                      _buildModernSwitchTile(
                        title: 'Daily Reminders',
                        subtitle: 'Get notified to practice Sunnah',
                        icon: Icons.notifications_active_rounded,
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                      ),
                      if (_notificationsEnabled) ...[
                        const SizedBox(height: 8),
                        _buildModernListTile(
                          title: 'Reminder Time',
                          subtitle: _reminderTime?.format(context) ?? 'Not set',
                          icon: Icons.schedule_rounded,
                          onTap: () => _selectTime(context),
                          showArrow: true,
                        ),
                      ],
                    ],
                  ),

                  // App Information Section
                  _buildModernSectionCard(
                    title: 'App Information',
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.purple[600] ?? Colors.purple,
                    children: [
                      _buildModernListTile(
                        title: 'Version',
                        subtitle: '1.0.0',
                        icon: Icons.app_settings_alt_rounded,
                        onTap: null,
                        showArrow: false,
                      ),
                      const SizedBox(height: 8),
                      _buildModernListTile(
                        title: 'About Revive',
                        subtitle: 'Learn more about this app',
                        icon: Icons.mosque_rounded,
                        onTap: () => _showAboutDialog(context),
                        showArrow: true,
                      ),
                      const SizedBox(height: 8),
                      _buildModernListTile(
                        title: 'Privacy Policy',
                        subtitle: 'How we protect your privacy',
                        icon: Icons.privacy_tip_rounded,
                        onTap: () => _showPrivacyDialog(context),
                        showArrow: true,
                      ),
                      const SizedBox(height: 8),
                      _buildModernListTile(
                        title: 'Terms of Service',
                        subtitle: 'Our terms and conditions',
                        icon: Icons.description_rounded,
                        onTap: () => _showTermsDialog(context),
                        showArrow: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Support Section
                  _buildModernSectionCard(
                    title: 'Support & Feedback',
                    icon: Icons.support_agent_rounded,
                    iconColor: Colors.green[600] ?? Colors.green,
                    children: [
                      _buildModernListTile(
                        title: 'Contact Us',
                        subtitle: 'Get help and support',
                        icon: Icons.email_rounded,
                        onTap: () => _showContactDialog(context),
                        showArrow: true,
                      ),
                      const SizedBox(height: 8),
                      _buildModernListTile(
                        title: 'Send Feedback',
                        subtitle: 'Share your thoughts',
                        icon: Icons.feedback_rounded,
                        onTap: () => _showFeedbackDialog(context),
                        showArrow: true,
                      ),
                      const SizedBox(height: 8),
                      _buildModernListTile(
                        title: 'Rate App',
                        subtitle: 'Support us with a review',
                        icon: Icons.star_rounded,
                        onTap: () => _showRateDialog(context),
                        showArrow: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildModernSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value
            ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? Theme.of(context).primaryColor : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildModernListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
    required bool showArrow,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 6, minute: 0),
    );

    if (picked != null && picked != _reminderTime) {
      await _saveReminderTime(picked);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Revive'),
        content: const Text(
          'Revive is a mobile app designed to help Muslims practice forgotten Sunnahs through daily reminders and gamified motivation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Your privacy is important to us. We do not collect personal data. All your progress is stored locally on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text(
          'By using this app, you agree to use it responsibly and in accordance with Islamic principles.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text(
          'For support or questions, please email us at support@revive-app.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback'),
        content: const Text(
          'We value your feedback! Please share your thoughts to help us improve the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Revive'),
        content: const Text(
          'If you enjoy using Revive, please consider rating us on the app store to help others discover this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}
