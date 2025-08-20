import 'package:flutter/material.dart';

class Student {
  final String studentId;
  final String name;
  List<Course> enrolledCourses = [];

  Student({required this.studentId, required this.name});

  void enrollInCourse(Course course) {
    enrolledCourses.add(course);
  }
}

class Assignment {
  final String title;
  final DateTime dueDate;
  Map<Student, double?> grades = {};
  Set<Student> submissions = {};

  Assignment({required this.title, required this.dueDate});

  void submitAssignment(Student student) {
    submissions.add(student);
    grades.putIfAbsent(student, () => null);
  }

  void assignGrade(Student student, double grade) {
    if (submissions.contains(student)) {
      grades[student] = grade;
    }
  }
}

class Course {
  final String courseName;
  final String courseId;
  List<Assignment> assignments = [];
  List<Student> enrolledStudents = [];

  Course({required this.courseName, required this.courseId});

  void enrollStudent(Student student) {
    enrolledStudents.add(student);
    student.enrollInCourse(this);
  }

  void addAssignment(Assignment assignment) {
    assignments.add(assignment);
  }

  void submitAssignment(Student student, Assignment assignment) {
    assignment.submitAssignment(student);
  }

  void assignGrade(Student student, Assignment assignment, double grade) {
    assignment.assignGrade(student, grade);
  }

  double calculateAverageGrade(Student student) {
    var grades = assignments
        .map((a) => a.grades[student])
        .where((g) => g != null)
        .cast<double>()
        .toList();
    if (grades.isEmpty) return 0.0;
    return grades.reduce((a, b) => a + b) / grades.length;
  }

  double get averageCourseGrade {
    var allGrades = <double>[];
    for (var a in assignments) {
      for (var g in a.grades.values) {
        if (g != null) allGrades.add(g);
      }
    }
    if (allGrades.isEmpty) return 0.0;
    return allGrades.reduce((a, b) => a + b) / allGrades.length;
  }

  List<MapEntry<Student, double>> topPerformers() {
    var averages = <Student, double>{};
    for (var s in enrolledStudents) {
      averages[s] = calculateAverageGrade(s);
    }
    var sorted = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  String generateReport() {
    var buffer = StringBuffer();
    buffer.writeln('Course Report: $courseName');
    buffer.writeln('=================================');
    buffer.writeln('Number of students: ${enrolledStudents.length}');
    buffer.writeln('Number of assignments: ${assignments.length}');
    buffer.writeln(
      'Average course grade: ${averageCourseGrade.toStringAsFixed(2)}',
    );
    buffer.writeln('\nTop 3 Performers:');
    var top3 = topPerformers();
    for (int i = 0; i < top3.length; i++) {
      buffer.writeln(
        '${i + 1}. ${top3[i].key.name} - ${top3[i].value.toStringAsFixed(2)}',
      );
    }
    buffer.writeln('\nAll Students:');
    for (var s in enrolledStudents) {
      buffer.writeln(
        '${s.name}: Avg ${calculateAverageGrade(s).toStringAsFixed(2)}',
      );
    }
    return buffer.toString();
  }
}

// ------------------ Flutter App ---------------------
class OnlineCourseApp extends StatefulWidget {
  const OnlineCourseApp({super.key});

  @override
  State<OnlineCourseApp> createState() => _OnlineCourseAppState();
}

class _OnlineCourseAppState extends State<OnlineCourseApp> {
  late Course course;

  @override
  void initState() {
    super.initState();
    _setupData();
  }

  void _setupData() {
    course = Course(courseName: 'Flutter Development', courseId: 'FL101');
    course.addAssignment(
      Assignment(title: 'Assignment 1', dueDate: DateTime(2025, 7, 20)),
    );
    course.addAssignment(
      Assignment(title: 'Assignment 2', dueDate: DateTime(2025, 8, 10)),
    );

    var Shubh = Student(studentId: 'S1', name: 'Shubh');
    var Samarth = Student(studentId: 'S2', name: 'Samarth');
    var Mir = Student(studentId: 'S3', name: 'Mir');
    var Disha = Student(studentId: 'S4', name: 'Disha');

    course.enrollStudent(Shubh);
    course.enrollStudent(Samarth);
    course.enrollStudent(Mir);
    course.enrollStudent(Disha);

    var a1 = course.assignments[0];
    var a2 = course.assignments[1];

    course.submitAssignment(Shubh, a1);
    course.submitAssignment(Samarth, a1);
    course.submitAssignment(Mir, a1);

    course.submitAssignment(Shubh, a2);
    course.submitAssignment(Samarth, a2);
    course.submitAssignment(Mir, a2);
    course.submitAssignment(Disha, a2);

    course.assignGrade(Shubh, a1, 85);
    course.assignGrade(Samarth, a1, 78);
    course.assignGrade(Mir, a1, 92);

    course.assignGrade(Shubh, a2, 88);
    course.assignGrade(Samarth, a2, 75);
    course.assignGrade(Mir, a2, 95);
    course.assignGrade(Disha, a2, 60);
  }

  @override
  Widget build(BuildContext context) {
    var top3 = course.topPerformers();

    return MaterialApp(
      title: 'Online Course Platform',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Online Course Platform'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              Text(
                '📚 Course: ${course.courseName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.blue[50],
                elevation: 3,
                child: ListTile(
                  title: Text(
                    '👥 Students Enrolled: ${course.enrolledStudents.length}',
                  ),
                  subtitle: Text(
                    '📝 Assignments: ${course.assignments.length}',
                  ),
                  trailing: Text(
                    '📊 Avg Grade: ${course.averageCourseGrade.toStringAsFixed(2)}',
                  ),
                ),
              ),
              const Divider(),
              Text(
                '🏆 Top 3 Performers:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...top3.asMap().entries.map((entry) {
                int index = entry.key;
                var student = entry.value.key;
                var avg = entry.value.value;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[(index + 1) * 200],
                    child: Text('${index + 1}'),
                  ),
                  title: Text(student.name),
                  subtitle: Text('Avg Grade: ${avg.toStringAsFixed(2)}'),
                  trailing: Icon(Icons.star, color: Colors.amber[600]),
                );
              }),
              const Divider(),
              Text(
                '🎓 All Students:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...course.enrolledStudents.map((student) {
                double avg = course.calculateAverageGrade(student);
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(student.name),
                    subtitle: LinearProgressIndicator(
                      value: avg / 100,
                      color: avg > 85
                          ? Colors.green
                          : (avg > 70 ? Colors.orange : Colors.red),
                      backgroundColor: Colors.grey[300],
                    ),
                    trailing: Text('${avg.toStringAsFixed(2)}'),
                  ),
                );
              }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          icon: const Icon(Icons.print),
          label: const Text('Print Report'),
          onPressed: () {
            String report = course.generateReport();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('📋 Course Report'),
                content: SingleChildScrollView(child: Text(report)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
