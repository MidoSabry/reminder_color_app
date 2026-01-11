import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/reminder_model.dart';

class FullScreenReminderService {
  static final FullScreenReminderService instance = FullScreenReminderService._init();
  
  FullScreenReminderService._init();

  // Initialize the alarm service
  Future<void> initialize() async {
    await Alarm.init();
  }


  

  // Schedule a full-screen reminder
  Future<void> scheduleReminder(ReminderModel reminder) async {
    // Check if time is in the future
    if (reminder.dateTime.isBefore(DateTime.now())) {
      debugPrint('Cannot schedule reminder in the past');
      return;
    }

   final alarmSettings = AlarmSettings(
  id: reminder.id.hashCode,
  dateTime: reminder.dateTime,
  assetAudioPath: 'assets/sounds/alarm.mp3',
  loopAudio: true,
  vibrate: true,
 androidFullScreenIntent: true, // ⭐ المهم
  warningNotificationOnKill: true,
  // Notification settings:
  notificationSettings: NotificationSettings(
    title: '${reminder.sticker} ${reminder.title}',
    body: reminder.note,
    stopButton: 'Stop', // optional
    icon: 'notification_icon', // optional
    iconColor: Colors.red,    // optional
  ),

  // Volume / fade settings:
  volumeSettings: VolumeSettings.fade(
    volume: 0.8,
    fadeDuration: const Duration(seconds: 3),
    volumeEnforced: true,
  ),

  // Android-specific flags:
  androidStopAlarmOnTermination: true,  // optional
);


    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint('Full-screen reminder scheduled for: ${reminder.dateTime}');
  }

  // Cancel reminder
  Future<void> cancelReminder(String id) async {
    await Alarm.stop(id.hashCode);
  }

  // Cancel all reminders
  Future<void> cancelAll() async {
    final alarms = await Alarm.getAlarms();
    for (var alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
  }

  // Get all scheduled alarms
  Future<List<AlarmSettings>> getAllAlarms() async {
    return await Alarm.getAlarms();
  }

  // Check if alarm is ringing
  static Stream<AlarmSettings> get ringStream => Alarm.ringStream.stream;


   // ← هنا نضيف الدالة اللي تجيب reminder من قاعدة البيانات
  Future<ReminderModel?> getReminderById(String id) async {
    final db = DatabaseHelper.instance;
    final reminders = await db.getAllReminders();
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}