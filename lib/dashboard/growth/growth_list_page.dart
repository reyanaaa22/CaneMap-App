import 'package:flutter/material.dart';
import 'growth_detail_page.dart';

class GrowthListPage extends StatelessWidget {
  const GrowthListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fields = const [
      {'name': 'Field A - Stratths', 'status': 'Tillering', 'days': 127},
      {'name': 'Field B - North Lot', 'status': 'Germination', 'days': 45},
      {'name': 'Field C - Creekside', 'status': 'Grand Growth', 'days': 210},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Tracker')),
      body: ListView.separated(
        itemCount: fields.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final f = fields[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2F8F46),
              child: const Icon(Icons.grass, color: Colors.white),
            ),
            title: Text(f['name'] as String),
            subtitle: Text('${f['status']} • ${f['days']} days'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    GrowthDetailPage(fieldName: f['name'] as String),
              ),
            ),
          );
        },
      ),
    );
  }
}
