import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
  
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  static const String _reminderChannelId = 'fyniq_daily_reminder';
  static const String _budgetChannelId = 'fyniq_budget_alerts';
  
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap — navigate to dashboard if needed
      },
    );
    
    // Create notification channels (Android 8+)
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _reminderChannelId, 'Daily Reminder',
        description: 'Daily reminder to log expenses',
        importance: Importance.high,
      ));
    
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _budgetChannelId, 'Budget Alerts',
        description: 'Alerts when approaching budget limits',
        importance: Importance.high,
      ));
  }
  
  Future<void> requestPermission() async {
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  }
  
  Future<void> scheduleDailyReminder(TimeOfDay time, String userName) async {
    await _plugin.cancel(0); // Cancel existing
    
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _plugin.zonedSchedule(
      0,
      '💸 Hey ${userName.isNotEmpty ? userName : "there"}, stay sharp!',
      'Log today\'s spends and outsmart your budget.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          'Daily Reminder',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF7C3AED),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  Future<void> cancelDailyReminder() => _plugin.cancel(0);
  
  Future<void> showBudgetAlert(String budgetId, String categoryName, double percentage) async {
    final prefs = await SharedPreferences.getInstance();
    final key75 = 'alert_${budgetId}_75';
    final key90 = 'alert_${budgetId}_90';
    
    if (percentage >= 90 && !(prefs.getBool(key90) ?? false)) {
      await prefs.setBool(key90, true);
      await _showBudgetNotification(
        id: budgetId.hashCode + 90,
        title: '🚨 Almost there!',
        body: '90% of your $categoryName budget is gone. Slow down.',
      );
    } else if (percentage >= 75 && !(prefs.getBool(key75) ?? false)) {
      await prefs.setBool(key75, true);
      await _showBudgetNotification(
        id: budgetId.hashCode + 75,
        title: '⚠️ Heads up!',
        body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your $categoryName budget.',
      );
    }
  }
  
  Future<void> showOverBudgetAlert(String categoryName) async {
    await _showBudgetNotification(
      id: categoryName.hashCode,
      title: '🚨 Limit crossed!',
      body: 'You\'ve exceeded your $categoryName budget. Review now.',
    );
  }
  
  Future<void> _showBudgetNotification({required int id, required String title, required String body}) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _budgetChannelId,
          'Budget Alerts',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFEC4899),
        ),
      ),
    );
  }

  // Expose plugin for manual usage in main.dart
  FlutterLocalNotificationsPlugin get plugin => _plugin;
}
