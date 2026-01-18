import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () => context.go('/enrollment'),
            tooltip: 'Enrollment Screen',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.people_outline,
            title: 'Manage Users',
            onTap: () => context.go('/admin/users'),
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            icon: Icons.book_outlined,
            title: 'Manage Courses',
            onTap: () => context.go('/admin/courses'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ),
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
