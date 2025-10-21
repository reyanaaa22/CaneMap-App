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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: _buildInputDecoration('Field Name', Icons.agriculture),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _areaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _buildInputDecoration('Size (hectares)', Icons.square_foot),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Location'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _barangay,
                    decoration: _buildInputDecoration('Barangay', Icons.location_city),
                    items: const [
                      DropdownMenuItem(
                        value: 'Alegria',
                        child: Text('Alegria'),
                      ),
                      DropdownMenuItem(
                        value: 'Dolores',
                        child: Text('Dolores'),
                      ),
                      DropdownMenuItem(value: 'Liloan', child: Text('Liloan')),
                    ],
                    onChanged: (v) => setState(() => _barangay = v),
                    validator: (v) => v == null ? 'Select barangay' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _municipality,
                    decoration: _buildInputDecoration('City/Municipality', Icons.location_on),
                    items: const [
                      DropdownMenuItem(
                        value: 'Ormoc City',
                        child: Text('Ormoc City'),
                      ),
                      DropdownMenuItem(
                        value: 'Kananga',
                        child: Text('Kananga'),
                      ),
                      DropdownMenuItem(
                        value: 'Albuera',
                        child: Text('Albuera'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _municipality = v),
                    validator: (v) => v == null ? 'Select municipality' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Map Location'),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                hintText: 'Search location or address...',
                prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                suffixIcon: _addressCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () {
                          _addressCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  FlutterMap(
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
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.canemap',
                      ),
                      MarkerLayer(
                        markers: _pin == null
                            ? const []
                            : [
                                Marker(
                                  point: _pin!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        _pin == null ? 'Tap to set location' : 'Location set',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Coordinates'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latCtrl,
                    readOnly: true,
                    decoration: _buildInputDecoration('Latitude', Icons.north),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtrl,
                    readOnly: true,
                    decoration: _buildInputDecoration('Longitude', Icons.east),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Field Details'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _variety,
              decoration: _buildInputDecoration('Crop Variety', Icons.eco),
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
              initialValue: _terrain,
              decoration: _buildInputDecoration('Terrain Type', Icons.terrain),
              items: const [
                DropdownMenuItem(value: 'Flat', child: Text('Flat')),
                DropdownMenuItem(value: 'Rolling', child: Text('Rolling')),
                DropdownMenuItem(value: 'Hilly', child: Text('Hilly')),
              ],
              onChanged: (v) => setState(() => _terrain = v),
              validator: (v) => v == null ? 'Select terrain type' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F8F46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF2F8F46).withOpacity(0.3),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF2F8F46), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2F8F46), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
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
