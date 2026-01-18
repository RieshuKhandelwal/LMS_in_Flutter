import 'package:flutter/material.dart';
import 'package:myapp/features/admin/add_edit_teacher_dialog.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class TeacherManagementScreen extends StatefulWidget {
  const TeacherManagementScreen({super.key});

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<User>> _teachers;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  void _loadTeachers() {
    setState(() {
      _teachers = dbHelper.getTeacherList();
    });
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditTeacherDialog(onSuccess: _loadTeachers),
    );
  }

  void _showEditTeacherDialog(User teacher) {
    showDialog(
      context: context,
      builder: (context) =>
          AddEditTeacherDialog(teacher: teacher, onSuccess: _loadTeachers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Teachers')),
      body: FutureBuilder<List<User>>(
        future: _teachers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final teachers = snapshot.data ?? [];
          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found.'));
          }
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return ListTile(
                title: Text(teacher.username),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditTeacherDialog(teacher),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await dbHelper.deleteUser(teacher.id!);
                        _loadTeachers();
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
        onPressed: _showAddTeacherDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
