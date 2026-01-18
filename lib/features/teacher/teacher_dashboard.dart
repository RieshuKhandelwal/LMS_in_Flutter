import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/utils/database_helper.dart';

class TeacherDashboard extends StatefulWidget {
  final int teacherId;

  const TeacherDashboard({super.key, required this.teacherId});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final dbHelper = DatabaseHelper();
  late Future<List<Course>> _allCourses;

  @override
  void initState() {
    super.initState();
    _allCourses = dbHelper.getAllCourses();
  }

  void _assignCourse(int courseId) async {
    try {
      await dbHelper.assignCourse(widget.teacherId, courseId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully assigned to course!')),
      );
      setState(() {
        _allCourses = dbHelper.getAllCourses();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning course: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () => context.go('/enrollment'),
            tooltip: 'Enrollment Screen',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: _allCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No courses available.'),
            );
          } else {
            final courses = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                final isAssigned = course.teacherId == widget.teacherId;
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      course.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(course.description),
                    ),
                    trailing: isAssigned
                        ? const Chip(
                            label: Text('Assigned'),
                            backgroundColor: Colors.green,
                          )
                        : ElevatedButton(
                            onPressed: () => _assignCourse(course.id!),
                            child: const Text('Assign'),
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
