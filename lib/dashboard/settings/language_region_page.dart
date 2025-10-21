import 'package:flutter/material.dart';

class LanguageRegionPage extends StatefulWidget {
  const LanguageRegionPage({super.key});

  @override
  State<LanguageRegionPage> createState() => _LanguageRegionPageState();
}

class _LanguageRegionPageState extends State<LanguageRegionPage> {
  String _language = 'English';
  String _region = 'UTC+08';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language & Region')),
      body: ListView(
        children: [
          _selectTile('Language', _language, const [
            'English',
            'Filipino',
            'Bisaya',
          ], (v) => setState(() => _language = v)),
          _selectTile('Region / Time Zone', _region, const [
            'UTC+08',
            'UTC+09',
            'UTC+00',
          ], (v) => setState(() => _region = v)),
        ],
      ),
    );
  }

  Widget _selectTile(
    String title,
    String current,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.green.shade700,
      child: const Icon(Icons.language, color: Colors.white),
    ),
    title: Text(title),
    trailing: DropdownButton<String>(
      value: current,
      underline: const SizedBox.shrink(),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}
