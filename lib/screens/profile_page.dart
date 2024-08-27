import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_profile_page.dart'; // Ensure you have this import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _imageUrl; // Store the image URL
  String? _description; // Store the user description

  @override
  void initState() {
    super.initState();
    // Fetch user data on initialization
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Fetch user details from Firestore
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _imageUrl = userDoc['imageUrl'] ?? ''; // Set the image URL if exists
          _description = userDoc['description'] ?? ''; // Set the description if exists
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user email
            Text(
              'Email: ${user?.email ?? 'Not logged in'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 20),
            // Display user image if available
            Center(
              child: _imageUrl != null && _imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        _imageUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(), // Empty container if no image URL
            ),
            SizedBox(height: 10),
            // Display user description if available
            Text(
              _description != null && _description!.isNotEmpty
                  ? 'Description: $_description'
                  : 'No description provided.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),
            // Button to navigate to update profile page
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                  );
                  // Refresh the user data after coming back from update profile page
                  _fetchUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
