import 'package:flutter/material.dart';
import 'package:myapp/features/admin/add_edit_course_dialog.dart';
import 'package:myapp/features/admin/enroll_student_dialog.dart';
import 'package:myapp/models/course_model.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<Course>> _courses;
  late Future<List<User>> _teachers;

  @override
  void initState() {
    super.initState();
    _refreshCourses();
    _loadTeachers();
  }

  void _refreshCourses() {
    setState(() {
      _courses = dbHelper.getCourseList();
    });
  }

  void _loadTeachers() {
    _teachers = dbHelper.getTeacherList();
  }

  void _showAddEditCourseDialog({Course? course}) async {
    final teachers = await _teachers;
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AddEditCourseDialog(
        course: course,
        teachers: Future.value(teachers),
        onCourseUpdated: _refreshCourses,
      ),
    );
  }

  void _showEnrollStudentDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) =>
          EnrollStudentDialog(course: course, onStudentEnrolled: () {}),
    );
  }

  Future<void> _deleteCourse(int courseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await dbHelper.deleteCourse(courseId);
      _refreshCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Courses'), elevation: 2),
      body: FutureBuilder<List<Course>>(
        future: _courses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses found.'));
          } else {
            final courses = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.teal,
                          ),
                          tooltip: 'Enroll Student',
                          onPressed: () => _showEnrollStudentDialog(course),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          tooltip: 'Edit Course',
                          onPressed: () =>
                              _showAddEditCourseDialog(course: course),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Delete Course',
                          onPressed: () => _deleteCourse(course.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCourseDialog(),
        label: const Text('Add Course'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
