import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _fullName = '';
  String _email = '';
  String _mobile = '';
  String _newPassword = '';

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _fullName = data['fullName'] ?? '';
          _email = data['email'] ?? '';
          _mobile = data['mobile'] ?? '';
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load user data')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'fullName': _fullName, 'mobile': _mobile, 'email': _email});

      if (_email != user!.email) {
        await user!.updateEmail(_email);
      }

      if (_newPassword.isNotEmpty) {
        await user!.updatePassword(_newPassword);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } finally {
      setState(() {
        _isLoading = false;
        _newPassword = '';
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Clear user session, then navigate to login screen removing all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget _buildAvatar() {
    String displayLetter =
        _fullName.isNotEmpty ? _fullName[0].toUpperCase() : '';
    return CircleAvatar(
      radius: 48,
      backgroundColor: Colors.tealAccent,
      child:
          displayLetter.isNotEmpty
              ? Text(
                displayLetter,
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              )
              : Icon(Icons.person, size: 48, color: Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              )
              : user == null
              ? _buildLoginPrompt()
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Center(child: _buildAvatar()),
                      SizedBox(height: 24),
                      _buildTextField(
                        label: 'Full Name',
                        initialValue: _fullName,
                        onSaved: (val) => _fullName = val!,
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Enter your name'
                                    : null,
                      ),
                      SizedBox(height: 14),
                      _buildTextField(
                        label: 'Email',
                        initialValue: _email,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (val) => _email = val!,
                        validator:
                            (val) =>
                                val == null || !val.contains('@')
                                    ? 'Enter a valid email'
                                    : null,
                      ),
                      SizedBox(height: 14),
                      _buildTextField(
                        label: 'Mobile',
                        initialValue: _mobile,
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => _mobile = val!,
                        validator:
                            (val) =>
                                val == null || val.length < 6
                                    ? 'Enter a valid mobile number'
                                    : null,
                      ),
                      SizedBox(height: 14),
                      _buildTextField(
                        label: 'New Password',
                        hintText: 'Leave empty if no change',
                        obscureText: true,
                        onSaved: (val) => _newPassword = val ?? '',
                        validator: (val) {
                          if (val != null && val.isNotEmpty && val.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _updateProfile,
                        icon: Icon(Icons.save),
                        label: Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: Icon(Icons.logout),
                        label: Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, color: Colors.white54, size: 60),
            SizedBox(height: 12),
            Text(
              'Please login to view your profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hintText,
    String? initialValue,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: Colors.grey[300]),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.tealAccent),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
