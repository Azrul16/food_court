import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    // Hardcoded admin check
    if (_email == 'admin@gmail.com' && _password == '@admin123') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Admin login successful')));
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Firebase Auth login
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);

      // Fetch user role from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

      String role = userDoc.get('role') ?? 'user';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login successful')));

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) =>
                                value == null ||
                                        value.isEmpty ||
                                        !value.contains('@')
                                    ? 'Enter valid email'
                                    : null,
                        onSaved: (value) => _email = value!.trim(),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                        onSaved: (value) => _password = value!,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
