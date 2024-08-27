import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  String id;
  String name;
  String frequency;
  DateTime startDate;
  List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.startDate,
    required this.completedDates,
  });

  factory Habit.fromMap(Map<String, dynamic> data) {
    return Habit(
      id: data['id'],
      name: data['name'],
      frequency: data['frequency'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      completedDates: (data['completed_dates'] as List<dynamic>)
          .map((date) => (date as Timestamp).toDate())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'completed_dates': completedDates.map((date) => Timestamp.fromDate(date)).toList(),
    };
  }
}
