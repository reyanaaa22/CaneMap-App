import 'package:flutter/material.dart';
import 'create_task_form.dart';

enum TaskStatus { pending, ongoing, completed }

class HandlerTasksPage extends StatefulWidget {
  const HandlerTasksPage({super.key});

  @override
  State<HandlerTasksPage> createState() => _HandlerTasksPageState();
}

class _HandlerTasksPageState extends State<HandlerTasksPage> {
  TaskStatus? _filter;

  // Sample data for now; replace with real data source later.
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
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            tooltip: 'Create Task',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CreateTaskForm()));
              if (created is Map<String, dynamic>) {
                setState(() => _tasks.insert(0, created));
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _StatusChip(
                  label: 'All',
                  selected: _filter == null,
                  color: Colors.grey.shade300,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Pending',
                  selected: _filter == TaskStatus.pending,
                  color: const Color(0xFFFFE0B2),
                  textColor: const Color(0xFFEF6C00),
                  onTap: () => setState(() => _filter = TaskStatus.pending),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Ongoing',
                  selected: _filter == TaskStatus.ongoing,
                  color: const Color(0xFFBBDEFB),
                  textColor: const Color(0xFF1565C0),
                  onTap: () => setState(() => _filter = TaskStatus.ongoing),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Completed',
                  selected: _filter == TaskStatus.completed,
                  color: const Color(0xFFC8E6C9),
                  textColor: const Color(0xFF2E7D32),
                  onTap: () => setState(() => _filter = TaskStatus.completed),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final t = filtered[index];
                return ListTile(
                  leading: _statusDot(t['status'] as TaskStatus),
                  title: Text(
                    t['title'] as String,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${t['field']} • ${t['assignee']}',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Text(_statusLabel(t['status'] as TaskStatus)),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F8F46),
        onPressed: () async {
          final created = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateTaskForm()));
          if (created is Map<String, dynamic>) {
            setState(() => _tasks.insert(0, created));
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statusDot(TaskStatus status) {
    Color color;
    switch (status) {
      case TaskStatus.pending:
        color = const Color(0xFFEF6C00);
        break;
      case TaskStatus.ongoing:
        color = const Color(0xFF1565C0);
        break;
      case TaskStatus.completed:
        color = const Color(0xFF2E7D32);
        break;
    }
    return CircleAvatar(radius: 8, backgroundColor: color);
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

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = textColor ?? Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? fg.withAlpha((0.5 * 255).round())
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? fg : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
