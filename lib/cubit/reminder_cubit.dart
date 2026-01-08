import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

part 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notifications = NotificationService.instance;

  ReminderCubit() : super(ReminderInitial());

  Future<void> loadReminders() async {
    try {
      emit(ReminderLoading());
      final reminders = await _db.getAllReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  // Future<void> addReminder(ReminderModel reminder) async {
  //   try {
  //     await _db.insertReminder(reminder);
  //     await _notifications.scheduleReminder(reminder);
  //     await loadReminders();
  //   } catch (e) {
  //     emit(ReminderError(e.toString()));
  //   }
  // }

   Future<void> addReminder(ReminderModel reminder) async {
    try {
      await _db.insertReminder(reminder);

      // Handle Notification or Alarm
      if (reminder.reminderType == 'alarm' && reminder.songPath != null) {
        // Call a custom method for scheduling an alarm with music
        await _notifications.scheduleAlarmReminder(reminder);
      } else {
        // Handle the regular notification
        await _notifications.scheduleReminder(reminder);
      }

      // Reload reminders
      await loadReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  // Future<void> updateReminder(ReminderModel reminder) async {
  //   try {
  //     await _db.updateReminder(reminder);
  //     await _notifications.cancelReminder(reminder.id);
  //     if (!reminder.isCompleted) {
  //       await _notifications.scheduleReminder(reminder);
  //     }
  //     await loadReminders();
  //   } catch (e) {
  //     emit(ReminderError(e.toString()));
  //   }
  // }


  // Method to update an existing reminder
  Future<void> updateReminder(ReminderModel reminder) async {
    try {
      await _db.updateReminder(reminder);

      // Cancel the old reminder
      await _notifications.cancelReminder(reminder.id);

      // If the reminder is not completed, schedule it again
      if (!reminder.isCompleted) {
        if (reminder.reminderType == 'alarm' && reminder.songPath != null) {
          await _notifications.scheduleAlarmReminder(reminder);
        } else {
          await _notifications.scheduleReminder(reminder);
        }
      }

      // Reload reminders
      await loadReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }


  Future<void> deleteReminder(String id) async {
    try {
      await _db.deleteReminder(id);
      await _notifications.cancelReminder(id);
      await loadReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> toggleComplete(ReminderModel reminder) async {
    final updated = reminder.copyWith(isCompleted: !reminder.isCompleted);
    await updateReminder(updated);
  }


  
}