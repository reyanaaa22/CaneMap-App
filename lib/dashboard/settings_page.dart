import 'package:flutter/material.dart';
// hub imports only
import 'settings/display_appearance_page.dart';
import 'settings/notifications_page.dart';
import 'settings/language_region_page.dart';
import 'settings/privacy_security_page.dart';
import 'settings/system_data_page.dart';
import 'settings/account_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Hub page shows only category list with chevrons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _hubItem(
              icon: Icons.palette_outlined,
              title: 'Display & Appearance',
              subtitle: 'Theme, colors, font and layout',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DisplayAppearancePage()),
              ),
            ),
            _hubItem(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: 'Push, sound, vibration, reminders',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsPage(),
                ),
              ),
            ),
            _hubItem(
              icon: Icons.language_outlined,
              title: 'Language & Region',
              subtitle: 'Language and time zone',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageRegionPage()),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Security & Privacy',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _hubItem(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy & Security',
              subtitle: 'Password, 2FA, permissions',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'System',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _hubItem(
              icon: Icons.settings_outlined,
              title: 'System & Data',
              subtitle: 'Storage, backup, updates',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SystemDataPage())),
            ),
            _hubItem(
              icon: Icons.person_outline_rounded,
              title: 'Account Settings',
              subtitle: 'Profile and account',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _hubItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2F8F46).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2F8F46),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    ),
  );

  // Removed old per-control helpers from hub (panels/tiles) as they are now on subpages.
}

class _SimpleColorPicker extends StatefulWidget {
  final Color initial;
  const _SimpleColorPicker({required this.initial});

  @override
  State<_SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<_SimpleColorPicker> {
  late Color _selected = widget.initial;
  static const List<Color> _choices = [
    Color(0xFF7CCF00),
    Color(0xFF2F8F46),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFF00BCD4),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Accent Color'),
      content: SizedBox(
        width: 280,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _choices
              .map(
                (c) => GestureDetector(
                  onTap: () => setState(() => _selected = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selected == c
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
