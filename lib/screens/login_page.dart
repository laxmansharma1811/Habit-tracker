import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/screens/home_page.dart';
import 'register_page.dart'; // Import the Register Page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });

    try {
      // Attempt to sign in the user
      await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // If login is successful, navigate to the HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
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
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Login to your account',
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
                  _buildLoginButton(),
                  SizedBox(height: 20),
                  _buildRegisterText(),
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      child: Text('Login'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blueAccent, backgroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRegisterText() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: Text(
        'Create a new account',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
