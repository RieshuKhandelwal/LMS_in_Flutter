import '../models/course_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  // In-memory data stores
  final List<User> _users = [];
  final List<Course> _courses = [];
  final List<Map<String, int>> _enrollments = []; // { 'userId': id, 'courseId': id }

  // Counters for auto-incrementing IDs
  int _userCounter = 0;
  int _courseCounter = 0;

  DatabaseHelper._internal() {
    // Initialize with a default admin user
    _userCounter++;
    _users.add(
      User(
        id: _userCounter,
        username: 'admin',
        password: 'admin',
        role: 'admin',
      ),
    );
  }

  // User methods
  Future<int> insertUser(User user) async {
    _userCounter++;
    final newUser = User(
      id: _userCounter,
      username: user.username,
      password: user.password,
      role: user.role,
    );
    _users.add(newUser);
    return newUser.id!;
  }

  Future<int> updateUser(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return user.id!;
    } else {
      return 0;
    }
  }

  Future<User?> getUserByUsernameAndPassword(
    String username,
    String password,
  ) async {
    try {
      return _users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      return _users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<User>> getUsersByRole(String role) async {
    return _users.where((user) => user.role == role).toList();
  }

  Future<List<User>> getTeacherList() async {
    return _users.where((user) => user.role == 'teacher').toList();
  }

  Future<List<User>> getStudentList() async {
    return _users.where((user) => user.role == 'student').toList();
  }

  Future<void> deleteUser(int id) async {
    _users.removeWhere((user) => user.id == id);
    _enrollments.removeWhere((enrollment) => enrollment['userId'] == id);
  }

  Future<bool> isUsernameExists(String username) async {
    return _users.any((user) => user.username == username);
  }

  Future<List<User>> getUserList() async {
    return List<User>.from(_users);
  }

  // Course methods
  Future<int> insertCourse(Course course) async {
    _courseCounter++;
    final newCourse = Course(
      id: _courseCounter,
      name: course.name,
      description: course.description,
    );
    _courses.add(newCourse);
    return newCourse.id!;
  }

  Future<int> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      return course.id!;
    } else {
      return 0;
    }
  }
  
  Future<List<Course>> getAllCourses() async {
    return List<Course>.from(_courses);
  }

  Future<List<Course>> getCourseList() async {
    return List<Course>.from(_courses);
  }

  Future<void> deleteCourse(int id) async {
    _courses.removeWhere((course) => course.id == id);
    _enrollments.removeWhere((enrollment) => enrollment['courseId'] == id);
  }

  Future<void> assignCourse(int userId, int courseId) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      _courses[courseIndex] = _courses[courseIndex].copyWith(teacherId: userId);
    }
  }

  Future<List<Course>> getCoursesForTeacher(int teacherId) async {
    return _courses.where((course) => course.teacherId == teacherId).toList();
  }

  Future<void> enrollStudent(int courseId, int studentId) async {
    // Prevent duplicate enrollments
    if (!_enrollments.any(
      (e) => e['userId'] == studentId && e['courseId'] == courseId,
    )) {
      _enrollments.add({'userId': studentId, 'courseId': courseId});
    }
  }

  Future<List<Course>> getEnrolledCourses(int studentId) async {
    final courseIds = _enrollments
        .where((e) => e['userId'] == studentId)
        .map((e) => e['courseId'])
        .toSet();
    return _courses.where((course) => courseIds.contains(course.id)).toList();
  }

  Future<List<User>> getEnrolledStudents(int courseId) async {
    final studentIds = _enrollments
        .where((e) => e['courseId'] == courseId)
        .map((e) => e['userId'])
        .toSet();
    return _users.where((user) => studentIds.contains(user.id)).toList();
  }
}
