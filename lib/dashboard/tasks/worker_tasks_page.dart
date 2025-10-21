import 'package:flutter/material.dart';
import 'handler_tasks_page.dart';
import 'task_detail_page.dart';

class WorkerTasksPage extends StatefulWidget {
  const WorkerTasksPage({super.key});

  @override
  State<WorkerTasksPage> createState() => _WorkerTasksPageState();
}

class _WorkerTasksPageState extends State<WorkerTasksPage> {
  TaskStatus? _filter;

  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Inspect irrigation lines',
      'assignee': 'Juan D.',
      'field': 'Lot A1 - Nasugbu',
      'status': TaskStatus.pending,
      'date': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'title': 'Fertilizer application',
      'assignee': 'Maria L.',
      'field': 'Block B3 - Taysan',
      'status': TaskStatus.ongoing,
      'date': DateTime.now(),
    },
    {
      'title': 'Harvest coordination',
      'assignee': 'Team Alpha',
      'field': 'Field C',
      'status': TaskStatus.completed,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filter == null
        ? _tasks
        : _tasks.where((t) => t['status'] == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F3),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFF0F7F3),
        elevation: 0,
        title: const Text(
          'My Tasks',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: DropdownButton<TaskStatus?>(
                value: _filter,
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                icon: Icon(
                  Icons.expand_more,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                items: [
                  DropdownMenuItem<TaskStatus?>(
                    value: null,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2F8F46),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'All Tasks',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<TaskStatus?>(
                    value: TaskStatus.pending,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF6C00),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<TaskStatus?>(
                    value: TaskStatus.ongoing,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1565C0),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ongoing',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<TaskStatus?>(
                    value: TaskStatus.completed,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _filter = value);
                },
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No tasks found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final t = _tasks[index];
                      return _buildTaskCard(t, theme);
                    },
                    itemCount: filtered.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, ThemeData theme) {
    final status = task['status'] as TaskStatus;
    final statusColor = _getStatusColor(status);
    final statusLabel = _statusLabel(status);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(task: task),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${task['field']} • ${task['assignee']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFEF6C00);
      case TaskStatus.ongoing:
        return const Color(0xFF1565C0);
      case TaskStatus.completed:
        return const Color(0xFF2E7D32);
    }
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.ongoing:
        return 'Ongoing';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
