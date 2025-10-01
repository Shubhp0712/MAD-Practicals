import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/database_service.dart';
import 'add_edit_student_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final Student student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Student _student;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  // Refresh student data
  Future<void> _refreshStudent() async {
    if (_student.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedStudent = await _databaseService.getStudentById(
        _student.id!,
      );
      if (updatedStudent != null) {
        setState(() {
          _student = updatedStudent;
        });
      }
    } catch (e) {
      _showSnackBar('Error refreshing data: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Edit student
  void _editStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditStudentScreen(student: _student),
      ),
    );

    if (result == true) {
      _refreshStudent();
      _showSnackBar('Student updated successfully!', Colors.green);
    }
  }

  // Delete student
  void _deleteStudent() async {
    final confirmed = await _showDeleteConfirmation();

    if (confirmed == true && _student.id != null) {
      try {
        await _databaseService.deactivateStudent(_student.id!);
        _showSnackBar('Student deactivated successfully!', Colors.orange);
        Navigator.pop(context, true); // Return to previous screen
      } catch (e) {
        _showSnackBar('Error deactivating student: $e', Colors.red);
      }
    }
  }

  // Show delete confirmation
  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: Text(
          'Are you sure you want to deactivate ${_student.name}?\n\n'
          'This will mark the student as inactive but preserve their data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  // Show snack bar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _student.name,
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
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editStudent();
                    break;
                  case 'delete':
                    _deleteStudent();
                    break;
                  case 'refresh':
                    _refreshStudent();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStudent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              _buildProfileHeader(),

              const SizedBox(height: 24),

              // Personal Information
              _buildInfoSection(
                title: 'Personal Information',
                icon: Icons.person,
                children: [
                  _buildInfoItem(
                    'Full Name',
                    _student.name,
                    Icons.person_outline,
                  ),
                  _buildInfoItem('Email', _student.email, Icons.email_outlined),
                  _buildInfoItem('Phone', _student.phone, Icons.phone_outlined),
                  _buildInfoItem(
                    'Address',
                    _student.address,
                    Icons.location_on_outlined,
                    isMultiline: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Academic Information
              _buildInfoSection(
                title: 'Academic Information',
                icon: Icons.school,
                children: [
                  _buildInfoItem(
                    'Course',
                    _student.course,
                    Icons.school_outlined,
                  ),
                  _buildInfoItem(
                    'Semester',
                    '${_student.semester}',
                    Icons.class_outlined,
                  ),
                  _buildInfoItem(
                    'CGPA',
                    _student.cgpa.toStringAsFixed(2),
                    Icons.grade_outlined,
                  ),
                  _buildGradeInfoItem(),
                ],
              ),

              const SizedBox(height: 24),

              // Status & Dates
              _buildInfoSection(
                title: 'Status & Dates',
                icon: Icons.info,
                children: [
                  _buildStatusInfoItem(),
                  _buildInfoItem(
                    'Enrollment Date',
                    _formatDate(_student.enrollmentDate),
                    Icons.calendar_today_outlined,
                  ),
                  _buildInfoItem(
                    'Duration',
                    _getEnrollmentDuration(),
                    Icons.access_time_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Stats
              _buildQuickStats(),

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Build profile header
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: _getAvatarColor(),
            child: Text(
              _student.name.isNotEmpty ? _student.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Name and status
          Text(
            _student.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            _student.email,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _student.isActive ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _student.isActive ? 'ACTIVE' : 'INACTIVE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build info section
  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Build info item
  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build grade info item
  Widget _buildGradeInfoItem() {
    final grade = _student.gradeFromCGPA;
    Color gradeColor = _getGradeColor(grade);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.emoji_events, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: gradeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build status info item
  Widget _buildStatusInfoItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            _student.isActive ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: _student.isActive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _student.isActive ? 'Active Student' : 'Inactive Student',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _student.isActive ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build quick stats
  Widget _buildQuickStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.school,
                    label: 'Course Progress',
                    value: '${((_student.semester / 8) * 100).round()}%',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    label: 'Performance',
                    value: _getPerformanceText(),
                    color: _getGradeColor(_student.gradeFromCGPA),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.access_time,
                    label: 'Study Duration',
                    value:
                        '${_student.enrollmentDurationInYears.toStringAsFixed(1)} years',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.school,
                    label: 'Graduation',
                    value: _student.isEligibleForGraduation
                        ? 'Eligible'
                        : 'In Progress',
                    color: _student.isEligibleForGraduation
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build stat item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editStudent,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Student'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _deleteStudent,
            icon: const Icon(Icons.delete),
            label: const Text('Deactivate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getAvatarColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.brown,
    ];

    final index = _student.name.hashCode % colors.length;
    return colors[index.abs()];
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.green;
      case 'A':
        return Colors.lightGreen;
      case 'B+':
        return Colors.blue;
      case 'B':
        return Colors.lightBlue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getEnrollmentDuration() {
    final years = _student.enrollmentDurationInYears;
    if (years < 1) {
      final months = (years * 12).round();
      return '$months month${months != 1 ? 's' : ''}';
    } else {
      return '${years.toStringAsFixed(1)} year${years != 1.0 ? 's' : ''}';
    }
  }

  String _getPerformanceText() {
    if (_student.cgpa >= 9.0) return 'Excellent';
    if (_student.cgpa >= 8.0) return 'Very Good';
    if (_student.cgpa >= 7.0) return 'Good';
    if (_student.cgpa >= 6.0) return 'Average';
    if (_student.cgpa >= 5.0) return 'Below Avg';
    return 'Poor';
  }
}
