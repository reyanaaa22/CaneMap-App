import 'package:flutter/material.dart';
import 'handler_tasks_page.dart';

class CreateTaskForm extends StatefulWidget {
  const CreateTaskForm({super.key});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _assigneeCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time = const TimeOfDay(hour: 8, minute: 0);
  String? _field;
  bool _driversOnly = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _assigneeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Assignment Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Task Title',
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter task title',
                        filled: true,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LabeledField(
                    label: 'Select Field',
                    child: DropdownButtonFormField<String>(
                      initialValue: _field,
                      decoration: const InputDecoration(filled: true),
                      items: const [
                        DropdownMenuItem(
                          value: 'Lot A1 - Nasugbu',
                          child: Text('Lot A1 - Nasugbu'),
                        ),
                        DropdownMenuItem(
                          value: 'Block B3 - Taysan',
                          child: Text('Block B3 - Taysan'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _field = v),
                      validator: (v) => v == null ? 'Select field' : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Assigned Date',
                    child: InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date ?? now,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: now.add(const Duration(days: 365 * 2)),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          filled: true,
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _date == null
                              ? 'dd/mm/yyyy'
                              : '${_date!.month}/${_date!.day}/${_date!.year}',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LabeledField(
                    label: 'Assigned Time',
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(filled: true),
                        child: Text(_time?.format(context) ?? 'Select time'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Assigned to:',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _assigneeCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Select worker...',
                            filled: true,
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Switch(
                            value: _driversOnly,
                            onChanged: (v) => setState(() => _driversOnly = v),
                          ),
                          const Text('Show only workers with Driver Badge'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Task Description:',
              child: TextFormField(
                controller: _descCtrl,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Describe the task...',
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final created = {
                      'title': _titleCtrl.text.trim(),
                      'assignee': _assigneeCtrl.text.trim(),
                      'field': _field ?? 'Field',
                      'status': TaskStatus.pending,
                      'date': DateTime.now(),
                    };
                    Navigator.of(context).pop(created);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F8F46),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Assign Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
