import 'package:flutter/material.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class AddEditCourseDialog extends StatefulWidget {
  final Course? course;
  final Future<List<User>> teachers;
  final Function()? onCourseUpdated;

  const AddEditCourseDialog({
    super.key,
    this.course,
    required this.teachers,
    this.onCourseUpdated,
  });

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  User? _selectedTeacher;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _nameController.text = widget.course!.name;
      _descriptionController.text = widget.course!.description;
    }
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        id: widget.course?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        teacherId: _selectedTeacher?.id,
      );
      if (widget.course == null) {
        await dbHelper.insertCourse(course);
      } else {
        await dbHelper.updateCourse(course);
      }
      widget.onCourseUpdated?.call();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<User>>(
              future: widget.teachers,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return DropdownButtonFormField<User>(
                  initialValue: _selectedTeacher,
                  items: snapshot.data!.map((teacher) {
                    return DropdownMenuItem<User>(
                      value: teacher,
                      child: Text(teacher.username),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTeacher = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Assign Teacher',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveCourse, child: const Text('Save')),
      ],
    );
  }
}
