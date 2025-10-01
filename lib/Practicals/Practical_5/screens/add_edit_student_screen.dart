import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student.dart';
import '../services/database_service.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  bool get isEditing => student != null;

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _courseController;
  late TextEditingController _semesterController;
  late TextEditingController _cgpaController;
  late TextEditingController _addressController;

  // Form state
  bool _isLoading = false;
  DateTime _enrollmentDate = DateTime.now();
  bool _isActive = true;

  // Available courses for dropdown
  final List<String> _availableCourses = [
    'Computer Science',
    'Information Technology',
    'Electronics Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Chemical Engineering',
    'Business Administration',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // Initialize form controllers
  void _initializeControllers() {
    if (widget.isEditing) {
      final student = widget.student!;
      _nameController = TextEditingController(text: student.name);
      _emailController = TextEditingController(text: student.email);
      _phoneController = TextEditingController(text: student.phone);
      _courseController = TextEditingController(text: student.course);
      _semesterController = TextEditingController(
        text: student.semester.toString(),
      );
      _cgpaController = TextEditingController(text: student.cgpa.toString());
      _addressController = TextEditingController(text: student.address);
      _enrollmentDate = student.enrollmentDate;
      _isActive = student.isActive;
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _courseController = TextEditingController();
      _semesterController = TextEditingController();
      _cgpaController = TextEditingController();
      _addressController = TextEditingController();
      _enrollmentDate = DateTime.now();
      _isActive = true;
    }
  }

  // Dispose controllers
  void _disposeControllers() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    _semesterController.dispose();
    _cgpaController.dispose();
    _addressController.dispose();
  }

  // Validate form and save student
  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email already exists (for new students or when email is changed)
      final emailExists = await _databaseService.emailExists(
        _emailController.text.trim(),
        excludeId: widget.isEditing ? widget.student!.id : null,
      );

      if (emailExists) {
        _showErrorDialog(
          'Email Error',
          'A student with this email already exists.',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create student object
      final student = Student(
        id: widget.isEditing ? widget.student!.id : null,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        course: _courseController.text.trim(),
        semester: int.parse(_semesterController.text.trim()),
        cgpa: double.parse(_cgpaController.text.trim()),
        address: _addressController.text.trim(),
        enrollmentDate: _enrollmentDate,
        isActive: _isActive,
      );

      // Save to database
      if (widget.isEditing) {
        await _databaseService.updateStudent(student);
      } else {
        await _databaseService.insertStudent(student);
      }

      // Return success
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorDialog(
        'Database Error',
        'Failed to save student: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _enrollmentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _enrollmentDate) {
      setState(() {
        _enrollmentDate = picked;
      });
    }
  }

  // Show course picker
  void _showCoursePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Course',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableCourses.length,
                  itemBuilder: (context, index) {
                    final course = _availableCourses[index];
                    return ListTile(
                      title: Text(course),
                      onTap: () {
                        setState(() {
                          _courseController.text = course;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Student' : 'Add Student',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveStudent,
              child: Text(
                widget.isEditing ? 'UPDATE' : 'SAVE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionHeader(
                icon: Icons.person,
                title: 'Personal Information',
              ),
              const SizedBox(height: 16),

              // Name field
              _buildTextFormField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter student\'s full name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // Email field
              _buildTextFormField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone field
              _buildTextFormField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Address field
              _buildTextFormField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter complete address',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 32),

              // Academic Information Section
              _buildSectionHeader(
                icon: Icons.school,
                title: 'Academic Information',
              ),
              const SizedBox(height: 16),

              // Course field with picker
              _buildTextFormField(
                controller: _courseController,
                label: 'Course',
                hint: 'Select or enter course',
                icon: Icons.school_outlined,
                readOnly: false,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: _showCoursePicker,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course is required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // Semester and CGPA row
              Row(
                children: [
                  // Semester field
                  Expanded(
                    child: _buildTextFormField(
                      controller: _semesterController,
                      label: 'Semester',
                      hint: '1-8',
                      icon: Icons.class_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Semester is required';
                        }
                        final semester = int.tryParse(value.trim());
                        if (semester == null || semester < 1 || semester > 8) {
                          return 'Enter semester 1-8';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // CGPA field
                  Expanded(
                    child: _buildTextFormField(
                      controller: _cgpaController,
                      label: 'CGPA',
                      hint: '0.0-10.0',
                      icon: Icons.grade_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'CGPA is required';
                        }
                        final cgpa = double.tryParse(value.trim());
                        if (cgpa == null || cgpa < 0.0 || cgpa > 10.0) {
                          return 'Enter CGPA 0.0-10.0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Enrollment date picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Enrollment Date'),
                subtitle: Text(
                  '${_enrollmentDate.day}/${_enrollmentDate.month}/${_enrollmentDate.year}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selectDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

              const SizedBox(height: 16),

              // Active status switch
              SwitchListTile(
                title: const Text('Active Status'),
                subtitle: Text(
                  _isActive ? 'Student is active' : 'Student is inactive',
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveStudent,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.isEditing ? 'UPDATE STUDENT' : 'ADD STUDENT',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Build section header
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Build text form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
    );
  }
}
