class Student {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String course;
  final int semester;
  final double cgpa;
  final String address;
  final DateTime enrollmentDate;
  final bool isActive;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.semester,
    required this.cgpa,
    required this.address,
    required this.enrollmentDate,
    this.isActive = true,
  });

  // Convert Student object to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'course': course,
      'semester': semester,
      'cgpa': cgpa,
      'address': address,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  // Create Student object from Map (SQLite result)
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      course: map['course'] ?? '',
      semester: map['semester']?.toInt() ?? 1,
      cgpa: map['cgpa']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      enrollmentDate: DateTime.parse(map['enrollmentDate']),
      isActive: map['isActive'] == 1,
    );
  }

  // Convert to JSON for debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'course': course,
      'semester': semester,
      'cgpa': cgpa,
      'address': address,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create a copy of Student with updated fields
  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? course,
    int? semester,
    double? cgpa,
    String? address,
    DateTime? enrollmentDate,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      course: course ?? this.course,
      semester: semester ?? this.semester,
      cgpa: cgpa ?? this.cgpa,
      address: address ?? this.address,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, name: $name, email: $email, course: $course, semester: $semester, cgpa: $cgpa}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Student &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.course == course &&
        other.semester == semester &&
        other.cgpa == cgpa &&
        other.address == address &&
        other.enrollmentDate == enrollmentDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        course.hashCode ^
        semester.hashCode ^
        cgpa.hashCode ^
        address.hashCode ^
        enrollmentDate.hashCode ^
        isActive.hashCode;
  }

  // Helper methods for validation
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  bool get isValidCGPA {
    return cgpa >= 0.0 && cgpa <= 10.0;
  }

  bool get isValidSemester {
    return semester >= 1 && semester <= 8;
  }

  // Get CGPA grade
  String get gradeFromCGPA {
    if (cgpa >= 9.0) return 'A+';
    if (cgpa >= 8.0) return 'A';
    if (cgpa >= 7.0) return 'B+';
    if (cgpa >= 6.0) return 'B';
    if (cgpa >= 5.0) return 'C';
    if (cgpa >= 4.0) return 'D';
    return 'F';
  }

  // Get enrollment duration in years
  double get enrollmentDurationInYears {
    final now = DateTime.now();
    final difference = now.difference(enrollmentDate);
    return difference.inDays / 365.25;
  }

  // Check if student is eligible for graduation (assuming 4 years)
  bool get isEligibleForGraduation {
    return semester >= 8 && cgpa >= 5.0;
  }
}
