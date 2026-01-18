import 'package:flutter/material.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class EnrollStudentDialog extends StatefulWidget {
  final Course course;
  final Function() onStudentEnrolled;

  const EnrollStudentDialog(
      {super.key, required this.course, required this.onStudentEnrolled});

  @override
  State<EnrollStudentDialog> createState() => _EnrollStudentDialogState();
}

class _EnrollStudentDialogState extends State<EnrollStudentDialog> {
  final dbHelper = DatabaseHelper();
  late Future<List<User>> _students;
  User? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _students = dbHelper.getStudentList();
  }

  Future<void> _enrollStudent() async {
    if (_selectedStudent != null) {
      await dbHelper.enrollStudent(widget.course.id!, _selectedStudent!.id!);
      widget.onStudentEnrolled();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enroll Student in ${widget.course.name}'),
      content: SingleChildScrollView(
        child: FutureBuilder<List<User>>(
            future: _students,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return DropdownButtonFormField<User>(
                initialValue: _selectedStudent,
                items: snapshot.data!.map((student) {
                  return DropdownMenuItem<User>(
                    value: student,
                    child: Text(student.username),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStudent = value;
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Select Student', border: OutlineInputBorder()),
                isExpanded: true,
              );
            }),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _enrollStudent, child: const Text('Enroll')),
      ],
    );
  }
}
