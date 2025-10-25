import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'help_support_page.dart';
import 'about_page.dart';
import 'settings/notifications_page.dart';
import 'settings/privacy_security_page.dart';
import 'settings/account_settings_page.dart';

class MenuPage extends StatefulWidget {
  final VoidCallback? onBack;
  const MenuPage({super.key, this.onBack});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC8E6C9), Color(0xFF81C784)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reyna Marie Boyboy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Profile',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          _buildDarkModeToggle(),
                          _buildItemDivider(),
                          _buildSettingsTile(
                            icon: Icons.notifications_outlined,
                            iconColor: const Color(0xFF424242),
                            title: 'Notifications',
                            trailingText: 'On',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsSettingsPage(),
                                ),
                              );
                            },
                          ),
                          _buildItemDivider(),
                          _buildSettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: const Color(0xFF424242),
                            title: 'Privacy',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PrivacySecurityPage(),
                                ),
                              );
                            },
                          ),
                          _buildItemDivider(),
                          _buildSettingsTile(
                            icon: Icons.security_outlined,
                            iconColor: const Color(0xFF424242),
                            title: 'Security',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PrivacySecurityPage(),
                                ),
                              );
                            },
                          ),
                          _buildItemDivider(),
                          _buildSettingsTile(
                            icon: Icons.person_outline,
                            iconColor: const Color(0xFF424242),
                            title: 'Account',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AccountSettingsPage(),
                                ),
                              );
                            },
                          ),
                          _buildItemDivider(),
                          _buildSettingsTile(
                            icon: Icons.help_outline,
                            iconColor: const Color(0xFF424242),
                            title: 'Help',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HelpSupportPage(),
                                ),
                              );
                            },
                          ),
                          _buildItemDivider(),
                          _buildSettingsTile(
                            icon: Icons.info_outline,
                            iconColor: const Color(0xFF424242),
                            title: 'About',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AboutPage(),
                                ),
                              );
                            },
                          ),
                          _buildItemDivider(),
                          _buildLogoutButton(context),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
        child: SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFF1B5E20),
                  onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // TODO: Implement actual logout logic
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red.shade500,
              size: 22,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: Colors.red.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildIconBadge(
            icon: Icons.nightlight_round,
            backgroundColor: const Color(0xFF263238).withOpacity(0.12),
            iconColor: const Color(0xFF263238),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Switch.adaptive(
            activeColor: const Color(0xFF2F8F46),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212121),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildItemDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }

}
