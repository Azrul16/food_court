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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'fullName': _fullName,
            'age': _age,
            'mobile': _mobile,
            'email': _email,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration successful')));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.message}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child:
                _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, size: 64, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildField(
                                    label: 'Full Name',
                                    icon: Icons.person,
                                    onSaved: (val) => _fullName = val!,
                                    validator:
                                        (val) =>
                                            val == null || val.isEmpty
                                                ? 'Enter full name'
                                                : null,
                                  ),
                                  _buildField(
                                    label: 'Age',
                                    icon: Icons.calendar_today,
                                    keyboardType: TextInputType.number,
                                    onSaved: (val) => _age = int.parse(val!),
                                    validator: (val) {
                                      if (val == null || val.isEmpty)
                                        return 'Enter age';
                                      if (int.tryParse(val) == null)
                                        return 'Enter valid age';
                                      return null;
                                    },
                                  ),
                                  _buildField(
                                    label: 'Mobile',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    onSaved: (val) => _mobile = val!.trim(),
                                    validator:
                                        (val) =>
                                            val == null || val.isEmpty
                                                ? 'Enter mobile number'
                                                : null,
                                  ),
                                  _buildField(
                                    label: 'Email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (val) => _email = val!.trim(),
                                    validator:
                                        (val) =>
                                            val == null || !val.contains('@')
                                                ? 'Enter valid email'
                                                : null,
                                  ),
                                  _buildField(
                                    label: 'Password',
                                    icon: Icons.lock,
                                    obscureText: true,
                                    onSaved: (val) => _password = val!,
                                    validator:
                                        (val) =>
                                            val == null || val.length < 6
                                                ? 'Password must be at least 6 characters'
                                                : null,
                                  ),
                                  _buildField(
                                    label: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                    onSaved: (val) => _confirmPassword = val!,
                                    validator:
                                        (val) =>
                                            val == null || val.length < 6
                                                ? 'Confirm password must be at least 6 characters'
                                                : null,
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _register,
                                      child: Text('Register'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        backgroundColor: Colors.teal,
                                        textStyle: TextStyle(fontSize: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
