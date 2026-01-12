import 'package:home_widget/home_widget.dart';
import '../models/reminder_model.dart';
import 'package:flutter/foundation.dart';

class WidgetService {
  static final WidgetService instance = WidgetService._init();
  WidgetService._init();

  Future<void> initialize() async {
    // Set the App Group ID for iOS
    await HomeWidget.setAppGroupId('group.reminderColorApp');
  }

  Future<void> updateWidget(ReminderModel reminder) async {
    try {
      debugPrint('🔷 Updating widget with data:');
      debugPrint('Title: ${reminder.title}');
      debugPrint('Note: ${reminder.note}');
      debugPrint('Sticker: ${reminder.sticker}');
      debugPrint('BG Color: ${reminder.backgroundColor}');
      debugPrint('Text Color: ${reminder.textColor}');
      
      await HomeWidget.saveWidgetData<String>('reminder_id', reminder.id);
      await HomeWidget.saveWidgetData<String>('reminder_title', reminder.title);
      await HomeWidget.saveWidgetData<String>('reminder_note', reminder.note);
      await HomeWidget.saveWidgetData<String>('reminder_sticker', reminder.sticker);
      await HomeWidget.saveWidgetData<String>('reminder_bg_color', reminder.backgroundColor.toString());
      await HomeWidget.saveWidgetData<String>('reminder_text_color', reminder.textColor.toString());
      
      final result = await HomeWidget.updateWidget(
        androidName: 'ReminderWidgetProvider',
      );
      
      debugPrint('✅ Widget update result: $result');
    } catch (e) {
      debugPrint('❌ Error updating widget: $e');
    }
  }

  Future<void> removeWidget(String reminderId) async {
    try {
      debugPrint('🔷 Removing widget data');
      
      await HomeWidget.saveWidgetData<String?>('reminder_id', null);
      await HomeWidget.saveWidgetData<String>('reminder_title', 'No Reminder');
      await HomeWidget.saveWidgetData<String>('reminder_note', 'Add a reminder');
      
      await HomeWidget.updateWidget(
        androidName: 'ReminderWidgetProvider',
      );
      
      debugPrint('✅ Widget removed');
    } catch (e) {
      debugPrint('❌ Error removing widget: $e');
    }
  }
}