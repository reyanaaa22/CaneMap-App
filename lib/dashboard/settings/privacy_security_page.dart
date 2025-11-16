import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      _PrivacyOption(
        icon: Icons.password_outlined,
        title: 'Change Password / PIN',
        subtitle: 'Update your CaneMap sign-in credentials.',
        onTap: () {},
      ),
      _PrivacyOption(
        icon: Icons.verified_user_outlined,
        title: 'Two-Factor Authentication (2FA)',
        subtitle: 'Add an extra verification step when logging in.',
        onTap: () {},
      ),
      _PrivacyOption(
        icon: Icons.security_outlined,
        title: 'App Permissions',
        subtitle: 'Control what data CaneMap can access on your device.',
        onTap: () {},
      ),
      _PrivacyOption(
        icon: Icons.logout,
        title: 'Logout from all devices',
        subtitle: 'Sign out everywhere CaneMap is currently active.',
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A2F8F46),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2F8F46),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F5E1F),
                  letterSpacing: 0.2,
                ),
              ),

              // Subtitle
              const SizedBox(height: 8),
              const Text(
                'Manage how CaneMap keeps your account protected and in your control.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF526058),
                  height: 1.5,
                ),
              ),

              // Options list
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    return _buildOptionItem(context, options[index]);
                  },
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F0F0),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemCount: options.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildOptionItem(BuildContext context, _PrivacyOption option) {
  return Material(
    color: Colors.white,
    child: InkWell(
      onTap: option.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child:
                  Icon(option.icon, color: const Color(0xFF1B5E20), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D2A23),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF66736B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF5B665F),
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PrivacyOption {
  const _PrivacyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
