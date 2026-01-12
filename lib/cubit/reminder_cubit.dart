import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';
import '../database/database_helper.dart';
import '../services/reminder_service.dart';

part 'reminder_state.dart';



class ReminderCubit extends Cubit<ReminderState> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FullScreenReminderService _alarmService = FullScreenReminderService.instance;

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

  Future<void> addReminder(ReminderModel reminder) async {
    try {
      await _db.insertReminder(reminder);
      await _alarmService.scheduleReminder(reminder); // استخدم الـ alarm service
      await loadReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }


    Future<void> updateReminder(ReminderModel reminder) async {
    try {
      await _db.updateReminder(reminder);
      await _alarmService.cancelReminder(reminder.id);
      if (!reminder.isCompleted) {
        await _alarmService.scheduleReminder(reminder);
      }
      await loadReminders();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _db.deleteReminder(id);
      await _alarmService.cancelReminder(id);
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