import 'dart:async';
import '../models/student.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final List<Student> _students = [];
  int _nextId = 1;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 Initializing database...');

    await _addSampleData();

    _isInitialized = true;
    print('✅ Database initialized with ${_students.length} students');
  }

  Future<bool> testConnection() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await Future.delayed(const Duration(milliseconds: 100));
      return _isInitialized;
    } catch (e) {
      print('❌ Database connection test failed: $e');
      return false;
    }
  }

  Future<void> _addSampleData() async {
    final sampleStudents = [
      Student(
        name: 'samarth',
        email: 'samarth@university.edu',
        phone: '+91784563210',
        course: 'Computer Science',
        semester: 4,
        cgpa: 8.5,
        enrollmentDate: DateTime(2023, 8, 15),
        address: '123 address',
        isActive: true,
      ),
      Student(
        name: 'Jaimin',
        email: 'jaimin@university.edu',
        phone: '+913365287410',
        course: 'Information Technology',
        semester: 6,
        cgpa: 9.2,
        enrollmentDate: DateTime(2022, 8, 20),
        address: '456 changa',
        isActive: true,
      ),
      Student(
        name: 'Mir',
        email: 'mir@university.edu',
        phone: '+917894561230',
        course: 'Electronics Engineering',
        semester: 2,
        cgpa: 7.8,
        enrollmentDate: DateTime(2024, 1, 10),
        address: '789 Anand',
        isActive: false,
      ),
    ];

    for (final student in sampleStudents) {
      await insertStudent(student);
    }
  }

  Future<int> insertStudent(Student student) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final newStudent = Student(
        id: _nextId++,
        name: student.name,
        email: student.email,
        phone: student.phone,
        course: student.course,
        semester: student.semester,
        cgpa: student.cgpa,
        enrollmentDate: student.enrollmentDate,
        address: student.address,
        isActive: student.isActive,
      );

      _students.add(newStudent);
      print('✅ Student inserted with ID: ${newStudent.id}');
      return newStudent.id!;
    } catch (e) {
      print('❌ Error inserting student: $e');
      throw Exception('Failed to insert student: $e');
    }
  }

  Future<List<Student>> getAllStudents() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      print('📚 Retrieved ${_students.length} students');
      return List.from(_students);
    } catch (e) {
      print('❌ Error retrieving students: $e');
      throw Exception('Failed to retrieve students: $e');
    }
  }

  Future<List<Student>> getActiveStudents() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final activeStudents = _students.where((s) => s.isActive).toList();
      print('📖 Retrieved ${activeStudents.length} active students');
      return activeStudents;
    } catch (e) {
      print('❌ Error retrieving active students: $e');
      throw Exception('Failed to retrieve active students: $e');
    }
  }

  Future<Student?> getStudentById(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final student = _students.firstWhere((s) => s.id == id);
      print('🔍 Retrieved student: ${student.name}');
      return student;
    } catch (e) {
      print('❌ Student not found with ID: $id');
      return null;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        print('✅ Student updated: ${student.name}');
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      print('❌ Error updating student: $e');
      throw Exception('Failed to update student: $e');
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final initialLength = _students.length;
      _students.removeWhere((s) => s.id == id);
      final removedCount = initialLength - _students.length;

      if (removedCount > 0) {
        print('🗑️ Student deleted with ID: $id');
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      print('❌ Error deleting student: $e');
      throw Exception('Failed to delete student: $e');
    }
  }

  Future<void> deactivateStudent(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final index = _students.indexWhere((s) => s.id == id);
      if (index != -1) {
        _students[index] = Student(
          id: _students[index].id,
          name: _students[index].name,
          email: _students[index].email,
          phone: _students[index].phone,
          course: _students[index].course,
          semester: _students[index].semester,
          cgpa: _students[index].cgpa,
          enrollmentDate: _students[index].enrollmentDate,
          address: _students[index].address,
          isActive: false,
        );
        print('⏸️ Student deactivated with ID: $id');
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      print('❌ Error deactivating student: $e');
      throw Exception('Failed to deactivate student: $e');
    }
  }

  Future<List<Student>> searchStudents(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));

      final lowerQuery = query.toLowerCase();
      final results = _students.where((student) {
        return student.name.toLowerCase().contains(lowerQuery) ||
            student.email.toLowerCase().contains(lowerQuery) ||
            student.course.toLowerCase().contains(lowerQuery);
      }).toList();

      print('🔍 Search for "$query" returned ${results.length} results');
      return results;
    } catch (e) {
      print('❌ Error searching students: $e');
      throw Exception('Failed to search students: $e');
    }
  }

  Future<List<Student>> getStudentsByCourse(String course) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));

      final results = _students.where((s) => s.course == course).toList();
      print('📚 Found ${results.length} students in $course');
      return results;
    } catch (e) {
      print('❌ Error retrieving students by course: $e');
      throw Exception('Failed to get students by course: $e');
    }
  }

  Future<List<Student>> getStudentsBySemester(int semester) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));

      final results = _students.where((s) => s.semester == semester).toList();
      print('📅 Found ${results.length} students in semester $semester');
      return results;
    } catch (e) {
      print('❌ Error retrieving students by semester: $e');
      throw Exception('Failed to get students by semester: $e');
    }
  }

  Future<List<String>> getAvailableCourses() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final courses = _students.map((s) => s.course).toSet().toList();
      courses.sort();
      print('📖 Available courses: ${courses.join(', ')}');
      return courses;
    } catch (e) {
      print('❌ Error retrieving courses: $e');
      throw Exception('Failed to get available courses: $e');
    }
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final total = _students.length;
      final active = _students.where((s) => s.isActive).length;
      final inactive = total - active;

      final totalCGPA = _students.fold<double>(0.0, (sum, s) => sum + s.cgpa);
      final avgCGPA = total > 0 ? totalCGPA / total : 0.0;

      final courseMap = <String, int>{};
      for (final student in _students) {
        courseMap[student.course] = (courseMap[student.course] ?? 0) + 1;
      }
      final courseDistribution =
          courseMap.entries
              .map((e) => {'course': e.key, 'count': e.value})
              .toList()
            ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      final semesterMap = <int, int>{};
      for (final student in _students) {
        semesterMap[student.semester] =
            (semesterMap[student.semester] ?? 0) + 1;
      }
      final semesterDistribution =
          semesterMap.entries
              .map((e) => {'semester': e.key, 'count': e.value})
              .toList()
            ..sort(
              (a, b) => (a['semester'] as int).compareTo(b['semester'] as int),
            );

      final stats = {
        'totalStudents': total,
        'activeStudents': active,
        'inactiveStudents': inactive,
        'averageCGPA': avgCGPA,
        'courseDistribution': courseDistribution,
        'semesterDistribution': semesterDistribution,
      };

      print('📊 Generated database statistics');
      return stats;
    } catch (e) {
      print('❌ Error generating statistics: $e');
      throw Exception('Failed to generate statistics: $e');
    }
  }

  Future<bool> emailExists(String email, {int? excludeId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      return _students.any(
        (student) =>
            student.email.toLowerCase() == email.toLowerCase() &&
            student.id != excludeId,
      );
    } catch (e) {
      print('❌ Error checking email existence: $e');
      return false;
    }
  }

  Future<void> close() async {
    print('📤 Database service closed');
  }
}
