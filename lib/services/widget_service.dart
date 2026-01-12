import 'package:home_widget/home_widget.dart';
import '../models/reminder_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class WidgetService {
  static final WidgetService instance = WidgetService._init();
  WidgetService._init();

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId('group.reminderColorApp');
  }

  /// 📌 Pin Reminder → Create NEW widget
 Future<void> pinReminder(ReminderModel reminder) async {
  debugPrint('📌 Pin widget for ${reminder.title}');

  // 1️⃣ خزّن بيانات الريمايندر
  await HomeWidget.saveWidgetData<String>(
    'last_pinned_reminder_id',
    reminder.id,
  );

  await HomeWidget.saveWidgetData<String>(
    'widget_reminder_${reminder.id}',
    jsonEncode(reminder.toMap()),
  );

  // 2️⃣ اطلب إضافة Widget جديد
  await HomeWidget.requestPinWidget(
    androidName: 'ReminderWidgetProvider',
  );
}


  /// 🔄 Update widget data if reminder edited
  Future<void> updateReminderWidget(ReminderModel reminder) async {
    await HomeWidget.saveWidgetData<String>(
      'widget_reminder_${reminder.id}',
      jsonEncode(reminder.toMap()),
    );

    await HomeWidget.updateWidget(
      androidName: 'ReminderWidgetProvider',
    );
  }
}
