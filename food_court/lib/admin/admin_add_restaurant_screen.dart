import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddRestaurantScreen extends StatefulWidget {
  @override
  _AdminAddRestaurantScreenState createState() => _AdminAddRestaurantScreenState();
}

class _AdminAddRestaurantScreenState extends State<AdminAddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _address = '';
  String _image = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('restaurants').add({
        'title': _title,
        'address': _address,
        'image': _image,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restaurant added successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add restaurant')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter title' : null,
                      onSaved: (value) => _title = value!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Address'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter address' : null,
                      onSaved: (value) => _address = value!.trim(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter image URL' : null,
                      onSaved: (value) => _image = value!.trim(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('Add Restaurant'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
