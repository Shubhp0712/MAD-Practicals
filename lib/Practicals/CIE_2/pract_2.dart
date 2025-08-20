import 'dart:io';

class Student {
  String id;
  String name;
  Map<String, int> marks = {};

  Student({required this.id, required this.name});

  void addMark(String subject, int mark) {
    if (mark < 0 || mark > 100) {
      throw ArgumentError('Mark must be between 0 and 100');
    }
    marks[subject] = mark;
  }

  double average() {
    if (marks.isEmpty) return 0.0;
    int total = marks.values.fold(0, (a, b) => a + b);
    return total / marks.length;
  }

  String getGrade() {
    double avg = average();
    if (avg >= 90) return 'A';
    if (avg >= 80) return 'B';
    if (avg >= 70) return 'C';
    if (avg >= 60) return 'D';
    return 'F';
  }
}

void printReport(List<Student> students) {
  for (var s in students) {
    print('Name: ${s.name}');
    print('Marks:');
    s.marks.forEach((subject, mark) {
      print('  $subject: $mark');
    });
    print('Average: ${s.average().toStringAsFixed(2)}');
    print('Grade: ${s.getGrade()}');
    print('----------------');
  }
}

List<Student> getFailures(List<Student> students) {
  return students.where((s) => s.getGrade() == 'F').toList();
}

Student? topStudent(List<Student> students) {
  if (students.isEmpty) return null;
  students.sort((a, b) => b.average().compareTo(a.average()));
  return students.first;
}

void main() {
  stdout.write('Enter number of students: ');
  int n = int.parse(stdin.readLineSync()!);
  List<Student> students = [];

  for (int i = 0; i < n; i++) {
    stdout.write('ID for student ${i + 1}: ');
    String id = stdin.readLineSync()!;
    stdout.write('Name for student ${i + 1}: ');
    String name = stdin.readLineSync()!;
    var student = Student(id: id, name: name);

    stdout.write('How many subjects for $name? ');
    int subjects = int.parse(stdin.readLineSync()!);

    for (int j = 0; j < subjects; j++) {
      stdout.write('  Subject ${j + 1} name: ');
      String subject = stdin.readLineSync()!;
      stdout.write('  Mark for $subject: ');
      int mark = int.parse(stdin.readLineSync()!);
      student.addMark(subject, mark);
    }
    students.add(student);
  }
}
