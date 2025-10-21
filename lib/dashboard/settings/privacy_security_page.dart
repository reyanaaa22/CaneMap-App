import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          _navTile(context, Icons.password, 'Change Password / PIN', () {}),
          _navTile(
            context,
            Icons.verified_user_outlined,
            'Two-Factor Authentication (2FA)',
            () {},
          ),
          _navTile(context, Icons.security_outlined, 'App Permissions', () {}),
          _navTile(context, Icons.logout, 'Logout from all devices', () {}),
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
