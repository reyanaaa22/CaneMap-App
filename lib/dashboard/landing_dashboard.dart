import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'map_page.dart';
import 'menu_page.dart';
import 'fields/register_field_page.dart';
import 'onboarding_tutorial.dart';
import 'driver_badge_application.dart';

class LandingDashboard extends StatefulWidget {
  const LandingDashboard({super.key});

  @override
  State<LandingDashboard> createState() => _LandingDashboardState();
}

class _LandingDashboardState extends State<LandingDashboard>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _showTutorial = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _currentCenter = LatLng(11.005, 124.607);
  final List<LatLng> _pins = [];
  late final AnimationController _dashboardController;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _mapOpacity;
  late final Animation<Offset> _mapSlide;
  late final Animation<double> _cardsOpacity;
  late final Animation<Offset> _cardsSlide;

  @override
  void initState() {
    super.initState();
    _pins.add(_currentCenter);
    _dashboardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _heroOpacity = CurvedAnimation(
      parent: _dashboardController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _heroSlide = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _dashboardController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _mapOpacity = CurvedAnimation(
      parent: _dashboardController,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );
    _mapSlide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _dashboardController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _cardsOpacity = CurvedAnimation(
      parent: _dashboardController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _cardsSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _dashboardController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _dashboardController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _dashboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F3),
      appBar: null,
      body: Stack(
        children: [
          _buildBody(),
          if (_showTutorial)
            OnboardingTutorial(
              onComplete: () {
                setState(() => _showTutorial = false);
              },
              onPageChange: (pageIndex) {
                setState(() => _index = pageIndex);
              },
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeroSection() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    String? firstName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts =
          displayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      if (parts.isNotEmpty) {
        firstName = parts.first;
      }
    }
    final String nameToShow = firstName ?? (user?.email ?? 'CaneMap User');
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
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
                    const Text(
                      'Normal Access',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildHeroActionButton(
                icon: Icons.add,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterFieldPage(),
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
          const SizedBox(height: 28),
          const Text(
            'Welcome to CaneMap',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Monitor your sugarcane fields, tasks, and weather insights all in one place.',
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
        controller: _searchCtrl,
        onSubmitted: _handleSearch,
        textInputAction: TextInputAction.search,
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
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.mic,
              color: Color(0xFF2F8F46),
              size: 22,
            ),
            onPressed: () => _handleSearch(_searchCtrl.text),
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
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

  Widget _buildBody() {
    switch (_index) {
      case 0:
        return _homeSummary();
      case 1:
        return MapPage(
          pins: _pins,
          mapController: _mapController,
          showHeader: true,
          onBack: () => setState(() => _index = 0),
        );
      case 2:
      default:
        return MenuPage(
          onBack: () => setState(() => _index = 0),
        );
    }
  }

  Widget _buildBottomNav() {
    final navItems = [
      (
        icon: _index == 0 ? Icons.home : Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      (
        icon: _index == 1 ? Icons.map : Icons.map_outlined,
        activeIcon: Icons.map,
        label: 'Map',
      ),
      (
        icon: _index == 2 ? Icons.person : Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Account',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(navItems.length, (i) {
          final isSelected = _index == i;
          final item = navItems[i];

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 48,
              decoration: BoxDecoration(
                color: _showTutorial
                    ? Colors.grey.shade300
                    : isSelected
                        ? const Color(0xFF2F8F46)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap:
                      _showTutorial ? null : () => setState(() => _index = i),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : _showTutorial
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: child,
                          ),
                        ),
                        child: isSelected
                            ? Padding(
                                key: ValueKey('label-${item.label}'),
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _homeSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _heroOpacity,
            child: SlideTransition(
              position: _heroSlide,
              child: _buildHeroSection(),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _mapOpacity,
            child: SlideTransition(
              position: _mapSlide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 280,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: MapPage(
                          pins: _pins,
                          mapController: _mapController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _cardsOpacity,
            child: SlideTransition(
              position: _cardsSlide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      icon: Icons.verified_user,
                      title: 'Apply for Driver Badge',
                      subtitle: 'Get verified and unlock premium features',
                      color: const Color(0xFF1E88E5),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DriverBadgeApplication(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFDCE9E1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F8F46),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.info,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Getting Started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2F5E1F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Register or join a field to get started\n2. Complete your profile and verification\n3. Access role-specific features once approved',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
      ),
    );
  }

  Future<void> _handleSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$trimmed&format=json&limit=1',
    );

    final response =
        await http.get(uri, headers: {'User-Agent': 'CaneMap-App (flutter)'});

    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body);
    if (data is! List || data.isEmpty) return;

    final lat = double.tryParse(data.first['lat']?.toString() ?? '');
    final lon = double.tryParse(data.first['lon']?.toString() ?? '');
    if (lat == null || lon == null) return;

    final target = LatLng(lat, lon);
    if (!mounted) return;

    setState(() {
      _currentCenter = target;
      _pins
        ..clear()
        ..add(target);
    });

    _mapController.move(target, 14);
  }
}
