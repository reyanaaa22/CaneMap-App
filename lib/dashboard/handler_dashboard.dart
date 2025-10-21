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
      appBar: _index == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFF0F7F3),
              title: _buildWeatherWidget(),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black87),
                  tooltip: 'Notifications',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16, left: 8),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF2F8F46),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )
          : null,
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
            // search row + mini map preview
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  _searchWithMic(),
                  const SizedBox(height: 16),
                  // map with decorative green bubbles using Stack
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        // map fills the area
                        Positioned.fill(
                          child: Container(
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
                        ),
                        // decorative green bubbles
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
            ),
            const SizedBox(height: 32),
          ],
        ),
      );

  Widget _noFieldHome() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  _searchWithMic(),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No registered field. Please register a field to access all features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
  Widget _mapPlaceholder() => Container(
    color: const Color(0xFFF0F7F3),
    child: MapPage(pins: [LatLng(11.005, 124.607)]),
  );
  Widget _tasksPlaceholder() => const HandlerTasksPage();
  Widget _profilePlaceholder() => const MenuPage();


  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Cloud background
              Icon(
                Icons.cloud,
                color: Colors.grey.shade700,
                size: 32,
              ),
              // Sun peeking from behind
              Positioned(
                right: -4,
                bottom: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA500),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '27°C',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Partly cloudy',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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

  Widget _searchWithMic() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF2F8F46),
              size: 22,
            ),
            suffixIcon: Icon(
              Icons.mic,
              color: const Color(0xFF2F8F46),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      );
}
