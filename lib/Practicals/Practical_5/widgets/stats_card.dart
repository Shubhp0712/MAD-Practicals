import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'Database Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatItem(
                  icon: Icons.people,
                  label: 'Total Students',
                  value: '${stats['totalStudents'] ?? 0}',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Active Students',
                  value: '${stats['activeStudents'] ?? 0}',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.cancel,
                  label: 'Inactive Students',
                  value: '${stats['inactiveStudents'] ?? 0}',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.grade,
                  label: 'Average CGPA',
                  value: '${stats['averageCGPA'] ?? 0.0}',
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildQuickInsights(),
          ],
        ),
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Build quick insights section
  Widget _buildQuickInsights() {
    final courseDistribution =
        stats['courseDistribution'] as List<dynamic>? ?? [];
    final semesterDistribution =
        stats['semesterDistribution'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Quick Insights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Most popular course
        if (courseDistribution.isNotEmpty)
          _buildInsightItem(
            icon: Icons.school,
            title: 'Most Popular Course',
            subtitle:
                '${courseDistribution.first['course']} (${courseDistribution.first['count']} students)',
            color: Colors.blue,
          ),

        // Most populated semester
        if (semesterDistribution.isNotEmpty)
          _buildInsightItem(
            icon: Icons.class_,
            title: 'Most Populated Semester',
            subtitle:
                'Semester ${semesterDistribution.first['semester']} (${semesterDistribution.first['count']} students)',
            color: Colors.green,
          ),

        // CGPA status
        _buildInsightItem(
          icon: Icons.grade,
          title: 'Average Performance',
          subtitle: _getCGPAStatus(stats['averageCGPA'] ?? 0.0),
          color: _getCGPAColor(stats['averageCGPA'] ?? 0.0),
        ),

        // Active vs Inactive ratio
        _buildInsightItem(
          icon: Icons.pie_chart,
          title: 'Student Status',
          subtitle: _getActiveRatio(),
          color: Colors.orange,
        ),
      ],
    );
  }

  // Build individual insight item
  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get CGPA status text
  String _getCGPAStatus(double avgCGPA) {
    if (avgCGPA >= 9.0)
      return 'Excellent overall performance (${avgCGPA.toStringAsFixed(2)})';
    if (avgCGPA >= 8.0)
      return 'Very good overall performance (${avgCGPA.toStringAsFixed(2)})';
    if (avgCGPA >= 7.0)
      return 'Good overall performance (${avgCGPA.toStringAsFixed(2)})';
    if (avgCGPA >= 6.0)
      return 'Average performance (${avgCGPA.toStringAsFixed(2)})';
    if (avgCGPA >= 5.0)
      return 'Below average performance (${avgCGPA.toStringAsFixed(2)})';
    return 'Poor overall performance (${avgCGPA.toStringAsFixed(2)})';
  }

  // Get CGPA color
  Color _getCGPAColor(double avgCGPA) {
    if (avgCGPA >= 8.0) return Colors.green;
    if (avgCGPA >= 7.0) return Colors.lightGreen;
    if (avgCGPA >= 6.0) return Colors.orange;
    if (avgCGPA >= 5.0) return Colors.deepOrange;
    return Colors.red;
  }

  // Get active ratio text
  String _getActiveRatio() {
    final total = stats['totalStudents'] ?? 0;
    final active = stats['activeStudents'] ?? 0;

    if (total == 0) return 'No students in database';

    final percentage = (active / total * 100).round();
    return '$percentage% active students ($active of $total)';
  }
}
