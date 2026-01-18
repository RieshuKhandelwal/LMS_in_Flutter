import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/admin/admin_dashboard.dart';
import 'package:myapp/features/admin/course_management_screen.dart';
import 'package:myapp/features/admin/student_management_screen.dart';
import 'package:myapp/features/admin/teacher_management_screen.dart';
import 'package:myapp/features/admin/user_management_screen.dart';
import 'package:myapp/features/auth/registration_screen.dart';
import 'package:myapp/features/enrollment/enrollment_screen.dart';
import 'package:myapp/features/student/student_dashboard.dart';
import 'package:myapp/features/teacher/teacher_dashboard.dart';

import 'features/auth/login_screen.dart';

void main() {
  // Ensure that Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

// Create the theme data outside of the widget for performance.
final ThemeData _appTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  // Coffee-inspired color palette
  const Color primarySeedColor = Color(0xFF6F4E37); // A rich coffee brown
  const Color secondaryColor = Color(0xFFC8A573); // A creamy latte color
  const Color backgroundColor = Color(
    0xFFF5F5DC,
  ); // A light beige/cream background

  // Coffee-inspired typography using Google Fonts
  final TextTheme appTextTheme = TextTheme(
    displayLarge: GoogleFonts.lora(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: primarySeedColor,
    ),
    titleLarge: GoogleFonts.lora(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: primarySeedColor,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: primarySeedColor.withAlpha(
        204,
      ), // Corrected: withAlpha instead of withOpacity
    ),
    labelLarge: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
      primary: primarySeedColor,
      secondary: secondaryColor,
      surface: backgroundColor, // Corrected: surface instead of background
    ),
    textTheme: appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: primarySeedColor,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.lora(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primarySeedColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: appTextTheme.labelLarge,
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: primarySeedColor,
      titleTextStyle: appTextTheme.titleLarge?.copyWith(fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primarySeedColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryColor, width: 2),
      ),
      labelStyle: GoogleFonts.roboto(color: primarySeedColor),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LMS App',
      debugShowCheckedModeBanner: false,
      theme: _appTheme,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
      routes: [
        GoRoute(
          path: 'users',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: 'students',
          builder: (context, state) => const StudentManagementScreen(),
        ),
        GoRoute(
          path: 'teachers',
          builder: (context, state) => const TeacherManagementScreen(),
        ),
        GoRoute(
          path: 'courses',
          builder: (context, state) => const CourseManagementScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/teacher/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TeacherDashboard(teacherId: id);
      },
    ),
    GoRoute(
      path: '/student/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return StudentDashboard(studentId: id);
      },
    ),
    GoRoute(
      path: '/enrollment',
      builder: (context, state) => const EnrollmentScreen(),
    ),
  ],
);
