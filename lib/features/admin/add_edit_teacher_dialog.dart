import 'package:flutter/material.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class AddEditTeacherDialog extends StatefulWidget {
  final User? teacher;
  final VoidCallback onSuccess;

  const AddEditTeacherDialog({
    super.key,
    this.teacher,
    required this.onSuccess,
  });

  @override
  State<AddEditTeacherDialog> createState() => _AddEditTeacherDialogState();
}

class _AddEditTeacherDialogState extends State<AddEditTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.teacher != null) {
      _usernameController.text = widget.teacher!.username;
      _passwordController.text = widget.teacher!.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.teacher == null ? 'Add Teacher' : 'Edit Teacher'),
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
        TextButton(onPressed: _saveTeacher, child: const Text('Save')),
      ],
    );
  }

  void _saveTeacher() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      if (widget.teacher == null) {
        await dbHelper.insertUser(
          User(username: username, password: password, role: 'teacher'),
        );
      } else {
        await dbHelper.updateUser(
          User(
            id: widget.teacher!.id,
            username: username,
            password: password,
            role: 'teacher',
          ),
        );
      }
      widget.onSuccess();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
