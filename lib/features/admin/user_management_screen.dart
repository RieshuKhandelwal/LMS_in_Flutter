import 'package:flutter/material.dart';
import 'package:myapp/features/admin/add_user_dialog.dart';
import 'package:myapp/features/admin/assign_course_dialog.dart';
import 'package:myapp/models/user_model.dart';
import 'package:myapp/utils/database_helper.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final dbHelper = DatabaseHelper();
  late Future<List<User>> _students;
  late Future<List<User>> _teachers;

  @override
  void initState() {
    super.initState();
    _refreshUserLists();
  }

  void _refreshUserLists() {
    setState(() {
      _students = dbHelper.getUsersByRole('student');
      _teachers = dbHelper.getUsersByRole('teacher');
    });
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(onUserAdded: _refreshUserLists),
    );
  }

  void _showAssignCourseDialog(User teacher) {
    showDialog(
      context: context,
      builder: (context) => AssignCourseDialog(
        teacher: teacher,
        onCourseAssigned: _refreshUserLists,
      ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this user?'),
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
      await dbHelper.deleteUser(userId);
      _refreshUserLists();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: 'Students', icon: Icon(Icons.person)),
              Tab(text: 'Teachers', icon: Icon(Icons.school)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(_students, 'student'),
            _buildUserList(_teachers, 'teacher'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddUserDialog,
          tooltip: 'Add User',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildUserList(Future<List<User>> futureUsers, String role) {
    return FutureBuilder<List<User>>(
      future: futureUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No ${role}s found.'));
        } else {
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(user.role[0].toUpperCase()),
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.role),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.role == 'teacher')
                        IconButton(
                          icon: const Icon(
                            Icons.assignment_ind,
                            color: Colors.blue,
                          ),
                          tooltip: 'Assign Course',
                          onPressed: () => _showAssignCourseDialog(user),
                        ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Delete User',
                        onPressed: () => _deleteUser(user.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
