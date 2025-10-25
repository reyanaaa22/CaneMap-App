import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard_models.dart';
import 'dynamic_bottom_nav.dart';
import 'map_page.dart';
import 'tasks/handler_tasks_page.dart';
import 'menu_page.dart';
import 'fields/register_field_page.dart';
import 'package:latlong2/latlong.dart';
import '../services/onboarding_service.dart';
import '../widgets/onboarding_overlay.dart';

class HandlerDashboard extends StatefulWidget {
  final bool hasField;
  const HandlerDashboard({super.key, this.hasField = true});

  @override
  State<HandlerDashboard> createState() => _HandlerDashboardState();
}

class _HandlerDashboardState extends State<HandlerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _mapPinKey = GlobalKey();
  int _index = 0;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingService.isOnboardingCompleted();
    if (!isCompleted && !widget.hasField) {
      setState(() {
        _showOnboarding = true;
      });
    }
  }

  void _completeOnboarding() async {
    await OnboardingService.setOnboardingCompleted();
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0F7F3),
      appBar: null,
      // drawer removed; hamburger icon will not appear
      body: _showOnboarding
          ? OnboardingOverlay(
              onComplete: _completeOnboarding,
              targetKeys: {
                'map_pin': _mapPinKey,
              },
              child: _buildBody(),
            )
          : _buildBody(),
      bottomNavigationBar: DynamicBottomNav(
        role: UserRole.handler,
        hasField: widget.hasField,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  Widget _buildBody() {
    if (!widget.hasField) {
      switch (_index) {
        case 0:
          return _noFieldHome();
        case 1:
          return _mapPlaceholder();
        case 2:
          return _registerFieldPage();
        case 3:
        default:
          return _profilePlaceholder();
      }
    }

    switch (_index) {
      case 0:
        return _homeSummary();
      case 1:
        return _mapPlaceholder();
      case 2:
        return _registerFieldPage();
      case 3:
        return _tasksPlaceholder();
      case 4:
      default:
        return _profilePlaceholder();
    }
  }

  Widget _registerFieldPage() {
    return const RegisterFieldPage();
  }

  Widget _homeSummary() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(
              title: 'Handler Dashboard',
              subtitle: 'Oversee your fields, teams, and tasks with ease.',
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: MapPage(pins: [LatLng(11.005, 124.607)]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.landscape,
                          title: 'Fields',
                          count: '12',
                          color: const Color(0xFF2F8F46),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.group,
                          title: 'Workers',
                          count: '8',
                          color: const Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.check_circle,
                          title: 'Tasks',
                          count: '24',
                          color: const Color(0xFFFFA500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _noFieldHome() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(
              title: 'Welcome, Handler',
              subtitle: 'Register your first field to start managing operations.',
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    key: _mapPinKey,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: MapPage(pins: [LatLng(11.005, 124.607)]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No registered field. Please register a field to access all features',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      );
  Widget _mapPlaceholder() => Container(
    color: const Color(0xFFF0F7F3),
    child: MapPage(pins: [LatLng(11.005, 124.607)]),
  );
  Widget _tasksPlaceholder() => const HandlerTasksPage();
  Widget _profilePlaceholder() => const MenuPage();


  Widget _buildHeroSection({
    required String title,
    required String subtitle,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    String? firstName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      if (parts.isNotEmpty) {
        firstName = parts.first;
      }
    }
    final nameToShow = firstName ?? (user?.email ?? 'Handler');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2F8F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameToShow,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Handler',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildHeroActionButton(
                icon: Icons.notifications_none,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildHeroActionButton(
                icon: Icons.cloud_outlined,
                backgroundColor: Colors.white,
                iconColor: const Color(0xFF2F8F46),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    Color iconColor = const Color(0xFF2F8F46),
  }) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search fields or locations',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF2F8F46),
            size: 22,
          ),
          suffixIcon: const Icon(
            Icons.mic,
            color: Color(0xFF2F8F46),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

}
