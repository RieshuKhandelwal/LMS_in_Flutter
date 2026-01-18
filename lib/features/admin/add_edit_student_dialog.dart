import 'package:flutter/material.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class AddEditStudentDialog extends StatefulWidget {
  final User? student;
  final VoidCallback onSuccess;

  const AddEditStudentDialog({
    super.key,
    this.student,
    required this.onSuccess,
  });

  @override
  State<AddEditStudentDialog> createState() => _AddEditStudentDialogState();
}

class _AddEditStudentDialogState extends State<AddEditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _usernameController.text = widget.student!.username;
      _passwordController.text = widget.student!.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _saveStudent, child: const Text('Save')),
      ],
    );
  }

  void _saveStudent() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      if (widget.student == null) {
        await dbHelper.insertUser(
          User(username: username, password: password, role: 'student'),
        );
      } else {
        await dbHelper.updateUser(
          User(
            id: widget.student!.id,
            username: username,
            password: password,
            role: 'student',
          ),
        );
      }
      widget.onSuccess();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
