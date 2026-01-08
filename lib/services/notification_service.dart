import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../screens/alarm_screen.dart'; // ← هنا الـ import
import '../main.dart'; // ← هنا الـ navigatorKey

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // ← هنا بنقول لما المستخدم يضغط على notification، نادي على _onNotificationTapped
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
  }

  // ← هنا الـ function اللي بتتنفذ لما المستخدم يضغط
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped! Payload: ${response.payload}');
    
    // لو الـ payload فيها "alarm:" يبقى دي alarm notification
    if (response.payload != null && response.payload!.startsWith('alarm:')) {
      // استخرج البيانات من الـ payload
      final parts = response.payload!.split('|');
      
      if (parts.length >= 6) {
        print('Opening AlarmScreen...');
        // ← هنا بننادي على AlarmScreen!
        _openAlarmScreen(
          title: parts[1],
          note: parts[2],
          sticker: parts[3],
          backgroundColor: int.parse(parts[4]),
          textColor: int.parse(parts[5]),
        );
      }
    }
  }

  // ← هنا الـ function اللي بتفتح AlarmScreen
  void _openAlarmScreen({
    required String title,
    required String note,
    required String sticker,
    required int backgroundColor,
    required int textColor,
  }) {
    // جيب الـ context من الـ navigatorKey
    final context = navigatorKey.currentContext;
    
    if (context != null) {
      // ← هنا بنفتح AlarmScreen!
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlarmScreen(
            title: title,
            note: note,
            sticker: sticker,
            backgroundColor: backgroundColor,
            textColor: textColor,
          ),
          fullscreenDialog: true, // علشان تفتح شاشة كاملة
        ),
      );
    } else {
      print('Context is null! Cannot open AlarmScreen');
    }
  }

  Future<void> _createNotificationChannels() async {
    const notificationChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Channel for reminder notifications',
      importance: Importance.high,
      playSound: true,
    );

    const alarmChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Channel for alarm notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alarmChannel);
  }

  Future<void> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Notification عادية
  Future<void> scheduleReminder(ReminderModel reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        reminder.note,
        contentTitle: '${reminder.sticker} ${reminder.title}',
        summaryText: 'Tap to view',
      ),
      color: Color(reminder.backgroundColor),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      '${reminder.sticker} ${reminder.title}',
      reminder.note,
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ← هنا بنعمل Alarm notification
  Future<void> scheduleAlarmReminder(ReminderModel reminder) async {
    // ← هنا بنحفظ كل البيانات في الـ payload
    final payload = 'alarm:${reminder.id}|${reminder.title}|${reminder.note}|${reminder.sticker}|${reminder.backgroundColor}|${reminder.textColor}';
    
    print('Scheduling alarm with payload: $payload');

    final androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      styleInformation: BigTextStyleInformation(
        reminder.note,
        contentTitle: '⏰ ALARM: ${reminder.sticker} ${reminder.title}',
        summaryText: 'Tap to open alarm',
      ),
      color: Colors.red,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_sound.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      '⏰ ALARM: ${reminder.sticker} ${reminder.title}',
      'Tap to open alarm screen',
      tz.TZDateTime.from(reminder.dateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload, // ← البيانات هنا!
    );
  }

  Future<void> cancelReminder(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}