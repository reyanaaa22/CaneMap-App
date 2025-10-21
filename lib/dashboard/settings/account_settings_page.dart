import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        children: [
          _navTile(context, Icons.edit_outlined, 'Edit Profile', () {}),
          _navTile(
            context,
            Icons.photo_camera_outlined,
            'Profile Picture',
            () {},
          ),
          _navTile(context, Icons.delete_outline, 'Delete Account', () {}),
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
