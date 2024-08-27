import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class AddHabitPage extends StatefulWidget {
  @override
  _AddHabitPageState createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String _habitName = '';
  String _frequency = 'daily';
  TimeOfDay _timeOfDay = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Habit',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildHabitNameField(),
                    SizedBox(height: 16),
                    _buildFrequencyDropdown(),
                    SizedBox(height: 16),
                    _buildTimePicker(),
                    SizedBox(height: 24),
                    _buildAddHabitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Habit Name',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a habit name';
        }
        return null;
      },
      onSaved: (value) {
        _habitName = value!;
      },
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _frequency,
      decoration: InputDecoration(
        labelText: 'Frequency',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      items: ['daily', 'weekly', 'monthly']
          .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _frequency = value!;
        });
      },
    );
  }

  Widget _buildTimePicker() {
    return ListTile(
      title: Text('Time of Day', style: TextStyle(color: Colors.white)),
      trailing: Text(_timeOfDay.format(context), style: TextStyle(color: Colors.white)),
      onTap: _selectTime,
      tileColor: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }

  Widget _buildAddHabitButton() {
    return ElevatedButton(
      child: Text('Add Habit'),
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (picked != null && picked != _timeOfDay) {
      setState(() {
        _timeOfDay = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _addHabitToFirestore();
    }
  }

  void _addHabitToFirestore() async {
    try {
      // Get today's date in YYYY-MM-DD format for unique habit entries
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Add the habit under the date key
      DocumentReference docRef = await _firestore.collection('habits').doc(dateKey).collection('tasks').add({
        'name': _habitName,
        'userId': _auth.currentUser!.uid,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'streak': 0,
        'frequency': _frequency,
        'timeOfDay': '${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}',
        'lastCompleted': null,
      });

      // Schedule reminder for the habit
      _scheduleReminder(docRef.id, _habitName, '${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}');

      // Navigate back after adding the habit
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add habit. Please try again.')),
      );
    }
  }

  Future<void> _scheduleReminder(String habitId, String habitName, String timeOfDay) async {
    final time = TimeOfDay.fromDateTime(DateTime.parse("2022-01-01 $timeOfDay:00"));
    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      // If the time is in the past, schedule for the next day
      scheduledDate.add(Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      habitId.hashCode,
      'Habit Reminder',
      'Time to complete your habit: $habitName',
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
