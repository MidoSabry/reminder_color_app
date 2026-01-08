import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final String title;
  final String note;
  final DateTime dateTime;
  final int textColor;
  final int backgroundColor;
  final String sticker;
  final bool isCompleted;
  final String reminderType; // New property: 'notification' or 'alarm'
  final String? songPath;   // New property for song path, null if not set


  const ReminderModel({
    required this.id,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.textColor,
    required this.backgroundColor,
    required this.sticker,
    this.isCompleted = false,
    required this.reminderType, // Initialize this
    this.songPath,  // Optional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'textColor': textColor,
      'backgroundColor': backgroundColor,
      'sticker': sticker,
      'isCompleted': isCompleted ? 1 : 0,
      'reminderType': reminderType,  // Add reminderType
      'songPath': songPath,          // Add songPath
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
      textColor: map['textColor'],
      backgroundColor: map['backgroundColor'],
      sticker: map['sticker'],
      isCompleted: map['isCompleted'] == 1,
      reminderType: map['reminderType'],  // Initialize reminderType
      songPath: map['songPath'],          // Initialize songPath
    );
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dateTime,
    int? textColor,
    int? backgroundColor,
    String? sticker,
    bool? isCompleted,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      sticker: sticker ?? this.sticker,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderType: reminderType ?? this.reminderType,  // Copy reminderType
      songPath: songPath ?? this.songPath,  // Copy songPath
    );
  }

  @override
  List<Object?> get props => [id, title, note, dateTime, textColor, backgroundColor, sticker, isCompleted, reminderType, songPath];
}