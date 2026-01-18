import 'package:flutter/material.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>> _enrollmentData;

  @override
  void initState() {
    super.initState();
    _enrollmentData = _getEnrollmentData();
  }

  Future<Map<String, dynamic>> _getEnrollmentData() async {
    final courses = await dbHelper.getAllCourses();
    final teachers = await dbHelper.getUsersByRole('teacher');

    final teacherMap = {for (var teacher in teachers) teacher.id: teacher.username};

    final courseEnrollments = <Course, Map<String, dynamic>>{};

    for (final course in courses) {
      final enrolledStudents = await dbHelper.getEnrolledStudents(course.id!);
      final teacherName = course.teacherId != null
          ? teacherMap[course.teacherId] ?? 'Teacher not found'
          : 'Not assigned yet';

      courseEnrollments[course] = {
        'teacher': teacherName,
        'students': enrolledStudents,
      };
    }

    return {'courses': courseEnrollments};
  }

  void _refreshEnrollmentData() {
    setState(() {
      _enrollmentData = _getEnrollmentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEnrollmentData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _enrollmentData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'An error occurred. No users may be created yet.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || (snapshot.data!['courses'] as Map).isEmpty) {
            return const Center(
              child: Text(
                'No courses have been created yet.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final courseEnrollments = snapshot.data!['courses'] as Map<Course, Map<String, dynamic>>;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Course', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Assigned Teacher', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Enrolled Students', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: courseEnrollments.entries.map((entry) {
                final course = entry.key;
                final details = entry.value;
                final teacher = details['teacher'] as String;
                final students = details['students'] as List<User>;

                return DataRow(
                  cells: [
                    DataCell(Text(course.name)),
                    DataCell(Text(teacher)),
                    DataCell(
                      students.isEmpty
                          ? const Text('No students enrolled')
                          : Text(students.map((s) => s.username).join(', ')),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
