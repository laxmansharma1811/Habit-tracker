import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  Future<void> _register() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      // Create a new user with the provided email and password
      await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // If registration is successful, navigate back to the login page
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Sign up to get started',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildEmailField(),
                  SizedBox(height: 20),
                  _buildPasswordField(),
                  SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  _buildRegisterButton(),
                  SizedBox(height: 20),
                  _buildLoginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          _email = value;
        });
      },
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: true,
      onChanged: (value) {
        setState(() {
          _password = value;
        });
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      child: Text('Register'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blueAccent, backgroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLoginText() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop(); // Navigate back to Login Page
      },
      child: Text(
        'Already have an account? Login',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
