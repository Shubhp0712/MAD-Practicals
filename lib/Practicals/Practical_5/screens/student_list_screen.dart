import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/database_service.dart';
import 'add_edit_student_screen.dart';
import 'student_details_screen.dart';
import '../widgets/student_card.dart';
import '../widgets/stats_card.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCourse = 'All';
  bool _showActiveOnly = true;

  // Future variables for FutureBuilder demonstration
  late Future<List<Student>> _studentsFuture;
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<String>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Refresh all data - demonstrates how to update FutureBuilder
  void _refreshData() {
    setState(() {
      _studentsFuture = _loadStudents();
      _statsFuture = _databaseService.getDatabaseStats();
      _coursesFuture = _databaseService.getAvailableCourses();
    });
  }
  Future<List<Student>> _loadStudents() async {
    try {
      final isConnected = await _databaseService.testConnection();
      if (!isConnected) {
        throw Exception('Database connection failed. Please restart the app.');
      }

      List<Student> students;

      if (_searchQuery.isNotEmpty) {
        students = await _databaseService.searchStudents(_searchQuery);
      } else if (_selectedCourse != 'All') {
        students = await _databaseService.getStudentsByCourse(_selectedCourse);
      } else if (_showActiveOnly) {
        students = await _databaseService.getActiveStudents();
      } else {
        students = await _databaseService.getAllStudents();
      }

      // Additional filtering if needed
      if (_showActiveOnly && _searchQuery.isNotEmpty) {
        students = students.where((student) => student.isActive).toList();
      }

      return students;
    } catch (e) {
      print('Error loading students: $e');
      throw Exception('Failed to load students: ${e.toString()}');
    }
  }

  // Search students
  void _searchStudents(String query) {
    setState(() {
      _searchQuery = query;
      _selectedCourse = 'All';
      _studentsFuture = _loadStudents();
    });
  }

  // Filter by course
  void _filterByCourse(String course) {
    setState(() {
      _selectedCourse = course;
      _searchQuery = '';
      _searchController.clear();
      _studentsFuture = _loadStudents();
    });
  }

  // Toggle active/all students
  void _toggleActiveFilter() {
    setState(() {
      _showActiveOnly = !_showActiveOnly;
      _studentsFuture = _loadStudents();
    });
  }

  // Navigate to add student screen
  void _addStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditStudentScreen()),
    );

    if (result == true) {
      _refreshData();
      _showSnackBar('Student added successfully!', Colors.green);
    }
  }

  // Navigate to edit student screen
  void _editStudent(Student student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditStudentScreen(student: student),
      ),
    );

    if (result == true) {
      _refreshData();
      _showSnackBar('Student updated successfully!', Colors.blue);
    }
  }

  // View student details
  void _viewStudent(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailsScreen(student: student),
      ),
    );
  }

  // Delete student with confirmation
  void _deleteStudent(Student student) async {
    final confirmed = await _showDeleteConfirmation(student);

    if (confirmed == true) {
      try {
        await _databaseService.deactivateStudent(student.id!);
        _refreshData();
        _showSnackBar('Student deactivated successfully!', Colors.orange);
      } catch (e) {
        _showSnackBar('Error deactivating student: $e', Colors.red);
      }
    }
  }

  // Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmation(Student student) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: Text(
          'Are you sure you want to deactivate ${student.name}?\n\n'
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

  // Show snackbar message
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Reset filters
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCourse = 'All';
      _showActiveOnly = true;
      _searchController.clear();
      _studentsFuture = _loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Student Records',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.list, color: Colors.white),
              text: 'Students',
            ),
            Tab(
              icon: Icon(Icons.analytics, color: Colors.white),
              text: 'Statistics',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(
              _showActiveOnly ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: _toggleActiveFilter,
            tooltip: _showActiveOnly ? 'Show All Students' : 'Show Active Only',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStudentListTab(), _buildStatisticsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStudent,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
        tooltip: 'Add New Student',
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Students list tab
  Widget _buildStudentListTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, email, or course...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchStudents('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _searchStudents,
          ),
        ),

        // Quick filters
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FutureBuilder<List<String>>(
            future: _coursesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final courses = ['All', ...snapshot.data!];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(course, style: const TextStyle(fontSize: 12)),
                      selected: _selectedCourse == course,
                      onSelected: (selected) => _filterByCourse(course),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Active filters display
        if (_searchQuery.isNotEmpty || _selectedCourse != 'All')
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getActiveFiltersText(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Students list with FutureBuilder
        Expanded(
          child: FutureBuilder<List<Student>>(
            future: _studentsFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading students...'),
                    ],
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading students',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Empty state
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getEmptyStateMessage(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add your first student',
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedCourse != 'All')
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: _resetFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ),
                    ],
                  ),
                );
              }

              // Data loaded successfully
              final students = snapshot.data!;
              return RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return StudentCard(
                      student: student,
                      onTap: () => _viewStudent(student),
                      onEdit: () => _editStudent(student),
                      onDelete: () => _deleteStudent(student),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Statistics tab with FutureBuilder
  Widget _buildStatisticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No statistics available'));
        }

        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StatsCard(stats: stats),
              const SizedBox(height: 16),
              _buildCourseDistribution(stats['courseDistribution']),
              const SizedBox(height: 16),
              _buildSemesterDistribution(stats['semesterDistribution']),
            ],
          ),
        );
      },
    );
  }

  // Build course distribution chart
  Widget _buildCourseDistribution(List<dynamic> courseStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Students by Course',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...courseStats.map((stat) {
              final course = stat['course'];
              final count = stat['count'];
              final maxCount = courseStats.isNotEmpty
                  ? courseStats
                        .map((s) => s['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                  : 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        course,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(value: count / maxCount),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Build semester distribution chart
  Widget _buildSemesterDistribution(List<dynamic> semesterStats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Students by Semester',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...semesterStats.map((stat) {
              final semester = stat['semester'];
              final count = stat['count'];
              final maxCount = semesterStats.isNotEmpty
                  ? semesterStats
                        .map((s) => s['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                  : 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Semester $semester',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(value: count / maxCount),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Get active filters text
  String _getActiveFiltersText() {
    List<String> filters = [];

    if (_searchQuery.isNotEmpty) {
      filters.add('Search: "$_searchQuery"');
    }

    if (_selectedCourse != 'All') {
      filters.add('Course: $_selectedCourse');
    }

    return 'Active filters: ${filters.join(', ')}';
  }

  // Get empty state message
  String _getEmptyStateMessage() {
    if (_searchQuery.isNotEmpty) {
      return 'No students found for "$_searchQuery"';
    } else if (_selectedCourse != 'All') {
      return 'No students found in $_selectedCourse';
    } else if (!_showActiveOnly) {
      return 'No students in database';
    } else {
      return 'No active students found';
    }
  }
}
