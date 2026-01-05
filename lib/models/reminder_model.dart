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

  const ReminderModel({
    required this.id,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.textColor,
    required this.backgroundColor,
    required this.sticker,
    this.isCompleted = false,
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
    );
  }

  @override
  List<Object?> get props => [id, title, note, dateTime, textColor, backgroundColor, sticker, isCompleted];
}