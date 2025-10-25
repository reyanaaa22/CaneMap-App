import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'field_application_draft.dart';
import 'docs_gallery_page.dart';

class FieldDetailsPage extends StatefulWidget {
  final FieldApplicationDraft draft;
  const FieldDetailsPage({super.key, required this.draft});

  @override
  State<FieldDetailsPage> createState() => _FieldDetailsPageState();
}

class _FieldDetailsPageState extends State<FieldDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _latCtrl = TextEditingController();
  final TextEditingController _lngCtrl = TextEditingController();

  String? _barangay;
  String? _municipality;
  String? _terrain;
  String? _variety;
  LatLng? _pin;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _nameCtrl.text = d.fieldName ?? '';
    _areaCtrl.text = d.sizeHa ?? '';
    _addressCtrl.text = d.address ?? '';
    _latCtrl.text = d.lat ?? '';
    _lngCtrl.text = d.lng ?? '';
    _barangay = d.barangay;
    _municipality = d.municipality;
    _terrain = d.terrain;
    _variety = d.cropVariety;
    if (d.lat != null && d.lng != null) {
      _pin = LatLng(
        double.tryParse(d.lat!) ?? 11.005,
        double.tryParse(d.lng!) ?? 124.607,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Field Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            _buildSectionCard(
              title: 'Basic Information',
              subtitle: 'Share the essentials about your field.',
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _buildInputDecoration('Field Name', icon: Icons.grass_outlined),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _areaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _buildInputDecoration('Size (hectares)', icon: Icons.straighten),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Location',
              subtitle: 'Specify where your field belongs.',
              children: [
                DropdownButtonFormField<String>(
                  value: _barangay,
                  isExpanded: true,
                  decoration: _buildInputDecoration('Barangay', icon: Icons.location_city_outlined),
                  items: const [
                    DropdownMenuItem(value: 'Alegria', child: Text('Alegria')),
                    DropdownMenuItem(value: 'Dolores', child: Text('Dolores')),
                    DropdownMenuItem(value: 'Liloan', child: Text('Liloan')),
                  ],
                  onChanged: (v) => setState(() => _barangay = v),
                  validator: (v) => v == null ? 'Select barangay' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _municipality,
                  isExpanded: true,
                  decoration: _buildInputDecoration('City / Municipality', icon: Icons.location_on_outlined),
                  items: const [
                    DropdownMenuItem(value: 'Ormoc City', child: Text('Ormoc City')),
                    DropdownMenuItem(value: 'Kananga', child: Text('Kananga')),
                    DropdownMenuItem(value: 'Albuera', child: Text('Albuera')),
                  ],
                  onChanged: (v) => setState(() => _municipality = v),
                  validator: (v) => v == null ? 'Select municipality' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Map Location',
              subtitle: 'Find and pin the exact spot on the map.',
              children: [
                TextField(
                  controller: _addressCtrl,
                  decoration: _buildInputDecoration('Search for an address or place', icon: Icons.search).copyWith(
                    suffixIcon: _addressCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Color(0xFF546E7A)),
                            onPressed: () {
                              _addressCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                _buildMapPreview(),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Coordinates',
              subtitle: 'Auto-filled once you drop a pin on the map.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latCtrl,
                        readOnly: true,
                        decoration: _buildInputDecoration('Latitude', icon: Icons.north_east),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lngCtrl,
                        readOnly: true,
                        decoration: _buildInputDecoration('Longitude', icon: Icons.south_east),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Field Details',
              subtitle: 'Optional information to complete your profile.',
              children: [
                DropdownButtonFormField<String>(
                  value: _variety,
                  isExpanded: true,
                  decoration: _buildInputDecoration('Crop Variety', icon: Icons.eco_outlined),
                  items: const [
                    DropdownMenuItem(value: 'Phil 8013', child: Text('Phil 8013')),
                    DropdownMenuItem(value: 'Phil 8829', child: Text('Phil 8829')),
                    DropdownMenuItem(value: 'Phil 9713', child: Text('Phil 9713')),
                  ],
                  onChanged: (v) => setState(() => _variety = v),
                  validator: (v) => v == null ? 'Select crop variety' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _terrain,
                  isExpanded: true,
                  decoration: _buildInputDecoration('Terrain Type', icon: Icons.terrain),
                  items: const [
                    DropdownMenuItem(value: 'Flat', child: Text('Flat')),
                    DropdownMenuItem(value: 'Rolling', child: Text('Rolling')),
                    DropdownMenuItem(value: 'Hilly', child: Text('Hilly')),
                  ],
                  onChanged: (v) => setState(() => _terrain = v),
                  validator: (v) => v == null ? 'Select terrain type' : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F8F46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0xFF2F8F46).withOpacity(0.35),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B4332),
              letterSpacing: 0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                height: 1.2,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFD7ECD9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _pin ?? LatLng(11.005, 124.607),
                initialZoom: 13,
                onTap: (tapPos, point) {
                  setState(() {
                    _pin = point;
                    _latCtrl.text = point.latitude.toStringAsFixed(6);
                    _lngCtrl.text = point.longitude.toStringAsFixed(6);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.canemap',
                ),
                MarkerLayer(
                  markers: _pin == null
                      ? const []
                      : [
                          Marker(
                            point: _pin!,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.location_pin,
                              color: Color(0xFFFB8C00),
                              size: 44,
                            ),
                          ),
                        ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.touch_app, size: 16, color: Color(0xFF2F8F46)),
                    SizedBox(width: 6),
                    Text(
                      'Tap to set location',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F8F46),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {IconData? icon}) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC7C7C7), width: 1),
    );

    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        color: Color(0xFF37474F),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      filled: true,
      fillColor: const Color(0xFFF1F3F4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFF2F8F46), width: 1.6),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              size: 20,
              color: const Color(0xFF2F8F46),
            ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }

  void _next() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_pin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pin your field location on the map'),
        ),
      );
      return;
    }
    final d = widget.draft;
    d.fieldName = _nameCtrl.text.trim();
    d.sizeHa = _areaCtrl.text.trim();
    d.address = _addressCtrl.text.trim();
    d.barangay = _barangay;
    d.municipality = _municipality;
    d.cropVariety = _variety;
    d.terrain = _terrain;
    d.lat = _latCtrl.text;
    d.lng = _lngCtrl.text;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DocsGalleryPage(draft: d)))
        .then((result) {
      if (result != null) {
        if (!mounted) return;
        Navigator.of(context).pop(result);
      }
    });
  }
}
