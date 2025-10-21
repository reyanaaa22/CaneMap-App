import 'package:flutter/material.dart';

class GrowthDetailPage extends StatelessWidget {
  final String fieldName;
  const GrowthDetailPage({super.key, required this.fieldName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('$fieldName - Stratths Status'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.search),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _harvestCard(),
          const SizedBox(height: 12),
          _infoGrid(),
          const SizedBox(height: 18),
          const Text(
            'Growth Timeline',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _timeline(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9EE27B),
                    side: const BorderSide(color: Color(0xFF9EE27B)),
                  ),
                  onPressed: () {},
                  child: const Text('Log Activity'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9EE27B),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  child: const Text('Export Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _harvestCard() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF69D043),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Harvest Estimate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          Text(
            'December 18, 2025',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _infoGrid() => Row(
    children: [
      Expanded(child: _infoTile('Crop Variety', 'Co 86002 Sugarcane')),
      const SizedBox(width: 10),
      Expanded(child: _infoTile('Days Since Planting', '127 Days')),
    ],
  );

  Widget _infoTile(String title, String value) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF3A3A3A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );

  Widget _timeline() => Column(
    children: [
      _timelineItem('Germination', 'Completed', Colors.green, 1.0),
      _timelineItem(
        'Germing Stage',
        'In Progress - August 25',
        Colors.green,
        0.5,
      ),
      _timelineItem('Tillering Stage', 'In Progress - Q1', Colors.green, 0.2),
      _timelineItem(
        'Grand Growth',
        'Expected - August 2025',
        Colors.white,
        0.0,
      ),
    ],
  );

  Widget _timelineItem(
    String title,
    String subtitle,
    Color color,
    double progress,
  ) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.expand_more, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '($subtitle)',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (progress > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFF3A3A3A),
                color: const Color(0xFF9EE27B),
              ),
            ),
        ],
      ),
    ),
  );
}
