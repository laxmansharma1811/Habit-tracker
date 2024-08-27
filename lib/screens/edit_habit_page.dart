import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditHabitPage extends StatefulWidget {
  final String habitId;
  final String habitName;
  final String frequency;
  final String timeOfDay;
  final bool completed;

  EditHabitPage({
    required this.habitId,
    required this.habitName,
    required this.frequency,
    required this.timeOfDay,
    required this.completed,
  });

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _habitName = '';
  String _frequency = '';
  TimeOfDay _timeOfDay = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _habitName = widget.habitName;
    _frequency = widget.frequency;
    List<String> timeParts = widget.timeOfDay.split(':');
    _timeOfDay = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
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
                      'Edit Habit',
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
                    _buildSaveChangesButton(),
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
      initialValue: _habitName,
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

  Widget _buildSaveChangesButton() {
    return ElevatedButton(
      child: Text('Save Changes'),
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blueAccent, backgroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 15),
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
      _updateHabitInFirestore();
    }
  }

  void _updateHabitInFirestore() async {
    try {
      await _firestore.collection('habits').doc(widget.habitId).update({
        'name': _habitName,
        'frequency': _frequency,
        'timeOfDay': '${_timeOfDay.hour.toString().padLeft(2, '0')}:${_timeOfDay.minute.toString().padLeft(2, '0')}',
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update habit. Please try again.')),
      );
    }
  }
}
