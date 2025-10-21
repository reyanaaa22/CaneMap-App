import 'package:flutter/material.dart';

class SystemDataPage extends StatelessWidget {
  const SystemDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System & Data')),
      body: ListView(
        children: [
          _navTile(
            context,
            Icons.storage_outlined,
            'Storage Management',
            () {},
          ),
          _navTile(context, Icons.backup_outlined, 'Backup & Restore', () {}),
          _navTile(
            context,
            Icons.system_update_alt_outlined,
            'App Version & Updates',
            () {},
          ),
          _navTile(context, Icons.restore_outlined, 'Reset to Default', () {}),
        ],
      ),
    );
  }

  Widget _navTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) => ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.green.shade700,
      child: Icon(icon, color: Colors.white),
    ),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
