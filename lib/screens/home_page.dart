import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/screens/login_page.dart';
import 'package:habit_tracker/screens/profile_page.dart';
import 'statistics_page.dart';
import 'add_habit_page.dart';
import 'edit_habit_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0; 

  final List<Widget> _pages = [
    HomePageContent(), // This should be a new widget or your existing HomePage content
    AddHabitPage(),   // Add your existing AddHabitPage
    ProfilePage(),    // Add a ProfilePage widget
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_currentIndex == 0) // Show only on Home tab
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatisticsPage()),
                );
              },
            ),
          if (_currentIndex == 0) 
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('habits')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return HabitTile(
              habitName: data['name'],
              habitCompleted: data['completed'] ?? false,
              streak: data['streak'] ?? 0,
              frequency: data['frequency'] ?? 'daily',
              timeOfDay: data['timeOfDay'] ?? '09:00',
              onTap: () => _toggleHabitCompletion(
                document.id,
                data['completed'] ?? false,
                data['streak'] ?? 0,
                data['lastCompleted'],
              ),
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHabitPage(
                      habitId: document.id,
                      habitName: data['name'],
                      frequency: data['frequency'] ?? 'daily',
                      timeOfDay: data['timeOfDay'] ?? '09:00',
                      completed: data['completed'] ?? false,
                    ),
                  ),
                );
              },
              onDelete: () => _deleteHabit(document.id),
            );
          }).toList(),
        );
      },
    );
  }

  void _toggleHabitCompletion(String habitId, bool currentState, int currentStreak, Timestamp? lastCompleted) {
    final now = Timestamp.now();
    int newStreak = currentStreak;

    if (!currentState) {
      // Completing the habit
      if (lastCompleted == null || _isConsecutiveDay(lastCompleted.toDate(), now.toDate())) {
        newStreak++;
      } else {
        newStreak = 1;
      }
    } else {
      // Uncompleting the habit
      newStreak = newStreak > 0 ? newStreak - 1 : 0;
    }

    _firestore.collection('habits').doc(habitId).update({
      'completed': !currentState,
      'streak': newStreak,
      'lastCompleted': !currentState ? now : null,
    });
  }

  bool _isConsecutiveDay(DateTime lastCompleted, DateTime now) {
    final difference = now.difference(lastCompleted).inDays;
    return difference == 1 || (difference == 0 && lastCompleted.day != now.day);
  }

  void _deleteHabit(String habitId) async {
    try {
      await _firestore.collection('habits').doc(habitId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Habit deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete habit. Please try again.')),
      );
    }
  }
}

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final int streak;
  final String frequency;
  final String timeOfDay;
  final Function()? onTap;
  final Function()? onEdit;
  final Function()? onDelete;

  const HabitTile({
    required this.habitName,
    required this.habitCompleted,
    required this.streak,
    required this.frequency,
    required this.timeOfDay,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          habitName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('Streak: $streak | $frequency at $timeOfDay'),
        leading: Checkbox(
          value: habitCompleted,
          onChanged: (bool? value) {
            if (onTap != null) {
              onTap!();
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
