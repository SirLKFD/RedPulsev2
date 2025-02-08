import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:redpulse/features/models/users.dart';

// Add this dialog widget to your ProfileScreen.dart file
class UpdateProfileDialog extends StatefulWidget {
  final UserAdminModel user;

  const UpdateProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  _UpdateProfileDialogState createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<UpdateProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName, _lastName, _phoneNumber, _address;

  @override
  void initState() {
    super.initState();

    // Attempt to split the existing full name into first and last names.
    // If the full name doesn't have a space, the last name will be empty.
    final names = widget.user.fullName.split(' ');
    _firstName = names.isNotEmpty ? names.first : '';
    _lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    _phoneNumber = widget.user.phoneNumber;
    _address = widget.user.address;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      // Combine first and last names into a full name
      final fullName = '$_firstName $_lastName'.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({
        'firstName': _firstName,
        'lastName': _lastName,
        'fullName': fullName,
        'phoneNumber': _phoneNumber,
        'address': _address,
      });

      Navigator.of(context).pop(true); // Close dialog and return true on success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
      Navigator.of(context).pop(false); // Close dialog on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Profile'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Name Field
              TextFormField(
                initialValue: _firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                onSaved: (value) => _firstName = value!,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter first name' : null,
              ),
              // Last Name Field
              TextFormField(
                initialValue: _lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                onSaved: (value) => _lastName = value!,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter last name' : null,
              ),
              // Phone Number Field
              TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onSaved: (value) => _phoneNumber = value!,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter phone number'
                    : null,
              ),
              // Address Field
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (value) => _address = value!,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter address' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateProfile,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
