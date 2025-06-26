import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  int _age = 0;
  String _mobile = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullName,
        'age': _age,
        'mobile': _mobile,
        'email': _email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
                      onSaved: (value) => _fullName = value!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter age';
                        if (int.tryParse(value) == null) return 'Enter valid age';
                        return null;
                      },
                      onSaved: (value) => _age = int.parse(value!),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Mobile'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? 'Enter mobile number' : null,
                      onSaved: (value) => _mobile = value!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || !value.contains('@') ? 'Enter valid email' : null,
                      onSaved: (value) => _email = value!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                      onSaved: (value) => _password = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) => value == null || value.length < 6 ? 'Confirm password must be at least 6 characters' : null,
                      onSaved: (value) => _confirmPassword = value!,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
