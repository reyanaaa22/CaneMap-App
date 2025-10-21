import 'package:flutter/material.dart';

class WorkerReportsPage extends StatefulWidget {
  const WorkerReportsPage({super.key});

  @override
  State<WorkerReportsPage> createState() => _WorkerReportsPageState();
}

class _WorkerReportsPageState extends State<WorkerReportsPage> {
  String _selectedFilter = 'week';

  final List<Map<String, dynamic>> _worklogs = [
    {
      'date': 'Oct 20, 2025',
      'field': 'Lot A1 - Nasugbu',
      'task': 'Inspect irrigation lines',
      'hours': 4.5,
      'status': 'Completed',
    },
    {
      'date': 'Oct 19, 2025',
      'field': 'Block B3 - Taysan',
      'task': 'Fertilizer application',
      'hours': 6.0,
      'status': 'Completed',
    },
    {
      'date': 'Oct 18, 2025',
      'field': 'Field C',
      'task': 'Harvest coordination',
      'hours': 5.5,
      'status': 'Completed',
    },
    {
      'date': 'Oct 17, 2025',
      'field': 'Lot A1 - Nasugbu',
      'task': 'Soil preparation',
      'hours': 3.0,
      'status': 'Completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalHours = _worklogs.fold<double>(0, (sum, log) => sum + (log['hours'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F3),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF0F7F3),
        elevation: 0,
        title: const Text(
          'Reports & Worklogs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStatsCard(totalHours),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterButton('week', 'This Week'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterButton('month', 'This Month'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildFilterButton('all', 'All Time'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Worklogs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _worklogs.length,
                itemBuilder: (context, index) {
                  final log = _worklogs[index];
                  return _buildWorklogCard(log);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(double totalHours) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  label: 'Total Hours',
                  value: '${totalHours.toStringAsFixed(1)}h',
                  color: const Color(0xFF2F8F46),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.assignment_turned_in,
                  label: 'Tasks Done',
                  value: '${_worklogs.length}',
                  color: const Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Avg Daily',
                  value: '${(totalHours / 4).toStringAsFixed(1)}h',
                  color: const Color(0xFFFFA500),
                ),
              ),
            ],
          ),
        ],
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F8F46) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2F8F46) : Colors.grey.shade300,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildWorklogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['date'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F8F46).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${log['hours']}h',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F8F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log['task'] as String,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            log['field'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
