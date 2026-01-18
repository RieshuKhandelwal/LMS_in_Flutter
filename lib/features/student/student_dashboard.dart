import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/utils/database_helper.dart';

class StudentDashboard extends StatefulWidget {
  final int studentId;

  const StudentDashboard({super.key, required this.studentId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final dbHelper = DatabaseHelper();
  late Future<List<Course>> _allCourses;
  late Future<List<Course>> _enrolledCourses;

  @override
  void initState() {
    super.initState();
    _allCourses = dbHelper.getAllCourses();
    _enrolledCourses = dbHelper.getEnrolledCourses(widget.studentId);
  }

  void _enrollInCourse(int courseId) async {
    try {
      await dbHelper.enrollStudent(courseId, widget.studentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully enrolled in course!')),
      );
      setState(() {
        _enrolledCourses = dbHelper.getEnrolledCourses(widget.studentId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enrolling in course: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_allCourses, _enrolledCourses]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No courses available.'));
          } else {
            final allCourses = snapshot.data![0] as List<Course>;
            final enrolledCourses = snapshot.data![1] as List<Course>;
            final enrolledCourseIds = enrolledCourses.map((c) => c.id).toSet();

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: allCourses.length,
              itemBuilder: (context, index) {
                final course = allCourses[index];
                final isEnrolled = enrolledCourseIds.contains(course.id);

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
                    trailing: isEnrolled
                        ? const Chip(
                            label: Text('Enrolled'),
                            backgroundColor: Colors.green,
                          )
                        : ElevatedButton(
                            onPressed: () => _enrollInCourse(course.id!),
                            child: const Text('Enroll'),
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
