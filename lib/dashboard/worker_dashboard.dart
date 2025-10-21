import 'package:flutter/material.dart';
import 'dashboard_models.dart';
import 'dynamic_bottom_nav.dart';
import 'map_page.dart';
import 'package:latlong2/latlong.dart';

class WorkerDashboard extends StatefulWidget {
  final bool hasJoinedField;
  const WorkerDashboard({super.key, this.hasJoinedField = true});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _buildBody(),
      bottomNavigationBar: DynamicBottomNav(
        role: UserRole.worker,
        hasField: widget.hasJoinedField,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  Widget _buildBody() {
    if (!widget.hasJoinedField) {
      switch (_index) {
        case 0:
          return _noJoinHome();
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
        return _reportsPlaceholder();
      case 4:
      default:
        return _profilePlaceholder();
    }
  }

  Widget _homeSummary() =>
      Center(child: Text('Worker Home: joined fields & pending requests'));
  Widget _noJoinHome() =>
      Center(child: Text('You have not joined a field yet'));
  Widget _mapPlaceholder() => MapPage(pins: [LatLng(11.005, 124.607)]);
  Widget _tasksPlaceholder() =>
      Center(child: Text('Assigned tasks & submit worklogs'));
  Widget _reportsPlaceholder() => Center(child: Text('Reports / Worklogs'));
  Widget _profilePlaceholder() =>
      Center(child: Text('Profile & Apply for Driver Badge'));
}
