import 'package:home_widget/home_widget.dart';
import '../models/reminder_model.dart';
import '../database/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class WidgetService {
  static final WidgetService instance = WidgetService._init();
  WidgetService._init();

  Future<void> initialize() async {
    // Set the App Group ID for iOS
    await HomeWidget.setAppGroupId('group.reminderColorApp');
  }

  // Update all pinned reminders
  Future<void> updateAllPinnedReminders() async {
    try {
      debugPrint('🔷 Updating all pinned reminders');
      
      // Get all reminders from database
      final db = DatabaseHelper.instance;
      final allReminders = await db.getAllReminders();
      
      // Filter only pinned ones
      final pinnedReminders = allReminders
          .where((r) => r.isPinnedToWidget && !r.isCompleted)
          .toList();
      
      debugPrint('📌 Found ${pinnedReminders.length} pinned reminders');
      
      // Convert to JSON
      final remindersJson = pinnedReminders.map((r) => {
        'id': r.id,
        'title': r.title,
        'note': r.note,
        'sticker': r.sticker,
        'backgroundColor': r.backgroundColor.toString(),
        'textColor': r.textColor.toString(),
      }).toList();
      
      final jsonString = jsonEncode(remindersJson);
      
      // Save to widget
      await HomeWidget.saveWidgetData<String>('reminders_list', jsonString);
      await HomeWidget.saveWidgetData<int>('reminders_count', pinnedReminders.length);
      
      final result = await HomeWidget.updateWidget(
        androidName: 'ReminderWidgetProvider',
      );
      
      debugPrint('✅ Widget update result: $result');
      debugPrint('📝 Saved ${pinnedReminders.length} reminders to widget');
    } catch (e) {
      debugPrint('❌ Error updating widget: $e');
    }
  }

  Future<void> updateWidget(ReminderModel reminder) async {
    // Just update all pinned reminders
    await updateAllPinnedReminders();
  }

  Future<void> removeWidget(String reminderId) async {
    // Just update all pinned reminders
    await updateAllPinnedReminders();
  }
}