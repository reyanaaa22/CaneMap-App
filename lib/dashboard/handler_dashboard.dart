import 'package:flutter/material.dart';
import 'dashboard_models.dart';
import 'dynamic_bottom_nav.dart';
import 'map_page.dart';
import 'tasks/handler_tasks_page.dart';
import 'menu_page.dart';
import 'fields/register_field_page.dart';
import 'growth/growth_list_page.dart';
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
  final GlobalKey _plusButtonKey = GlobalKey();
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
      backgroundColor: Colors.white,
      appBar: _index == 1
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: _buildWeatherWidget(),
              centerTitle: false,
              actions: [
                IconButton(
                  key: _plusButtonKey,
                  icon: const Icon(Icons.add, color: Colors.black87),
                  tooltip: 'Register Field',
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RegisterFieldPage()),
                    );
                    if (result != null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Field saved')),
                      );
                    }
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
            ),
      // drawer removed; hamburger icon will not appear
      body: _showOnboarding
          ? OnboardingOverlay(
              onComplete: _completeOnboarding,
              targetKeys: {
                'plus_button': _plusButtonKey,
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
        return _tasksPlaceholder();
      case 3:
        return _growthPlaceholder();
      case 4:
      default:
        return _profilePlaceholder();
    }
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
                  const SizedBox(height: 12),
                  // Features Section - Driver Badge Holder
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBadgeHolderCard(),
                    ],
                  ),
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
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: MapPage(pins: [LatLng(11.005, 124.607)]),
                          ),
                        ),
                        // decorative green bubbles
                        Positioned(
                          top: 8,
                          left: 12,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAF5E3),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromRGBO(47, 143, 70, 0.12),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.grass,
                              color: Color(0xFF2F8F46),
                              size: 18,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          right: 14,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF8EE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromRGBO(47, 143, 70, 0.14),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF2F8F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // horizontal product cards
            SizedBox(
              height: 140,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _productCard(
                    Icons.opacity,
                    'Irrigation',
                    'Monitor water',
                    Colors.teal,
                  ),
                  const SizedBox(width: 12),
                  _productCard(
                    Icons.thermostat,
                    'Weather',
                    'Forecasts',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _productCard(
                    Icons.local_florist,
                    'Crop',
                    'Growth tips',
                    Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Center(
                child: Text('Handler Home: summary of fields, workers, tasks')),
            const SizedBox(height: 24),
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
                  const SizedBox(height: 12),
                  Container(
                    key: _mapPinKey,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: MapPage(pins: [LatLng(11.005, 124.607)]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'No registered field. Please register a field to access all features',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
  Widget _mapPlaceholder() => Container(
    color: Colors.white,
    child: MapPage(pins: [LatLng(11.005, 124.607)]),
  );
  Widget _tasksPlaceholder() => const HandlerTasksPage();
  Widget _growthPlaceholder() => const GrowthListPage();
  Widget _profilePlaceholder() => const MenuPage();

  Widget _productCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) =>
      Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // green bubble background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Icon(icon, color: color, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      );

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

  Widget _buildBadgeHolderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Badge Holder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get verified and unlock premium features',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redirecting to application form...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchWithMic() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search fields or locations',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 4, right: 8),
                  child: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF2F8F46),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              bottom: 6,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F8F46), Color(0xFF1F6B2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2F8F46).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
