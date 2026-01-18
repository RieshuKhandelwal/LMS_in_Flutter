import 'package:flutter/material.dart';
import 'package:myapp/features/admin/add_edit_student_dialog.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<User>> _students;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _students = dbHelper.getStudentList();
    });
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditStudentDialog(onSuccess: _loadStudents),
    );
  }

  void _showEditStudentDialog(User student) {
    showDialog(
      context: context,
      builder: (context) =>
          AddEditStudentDialog(student: student, onSuccess: _loadStudents),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: FutureBuilder<List<User>>(
        future: _students,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(child: Text('No students found.'));
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text(student.username),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditStudentDialog(student),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await dbHelper.deleteUser(student.id!);
                        _loadStudents();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
