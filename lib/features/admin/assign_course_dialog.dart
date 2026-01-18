import 'package:flutter/material.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class AssignCourseDialog extends StatefulWidget {
  final User teacher;
  final Function() onCourseAssigned;

  const AssignCourseDialog({
    super.key,
    required this.teacher,
    required this.onCourseAssigned,
  });

  @override
  State<AssignCourseDialog> createState() => _AssignCourseDialogState();
}

class _AssignCourseDialogState extends State<AssignCourseDialog> {
  final dbHelper = DatabaseHelper();
  late Future<List<Course>> _courses;
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _courses = dbHelper.getCourseList();
  }

  Future<void> _assignCourse() async {
    if (_selectedCourse != null) {
      await dbHelper.assignCourse(widget.teacher.id!, _selectedCourse!.id!);
      widget.onCourseAssigned();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Course to ${widget.teacher.username}'),
      content: SingleChildScrollView(
        child: FutureBuilder<List<Course>>(
          future: _courses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return DropdownButtonFormField<Course>(
              initialValue: _selectedCourse,
              items: snapshot.data!.map((course) {
                return DropdownMenuItem<Course>(
                  value: course,
                  child: Text(course.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Course'),
              isExpanded: true,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _assignCourse, child: const Text('Assign')),
      ],
    );
  }
}
