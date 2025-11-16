import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../services/fields_service.dart';

class MapPage extends StatefulWidget {
  final List<LatLng> pins;
  final List<FieldPin>? fieldPins;
  final GlobalKey? firstPinKey;
  final MapController? mapController;
  final double zoom;
  final bool showHeader;
  final VoidCallback? onBack;
  const MapPage({
    super.key,
    this.pins = const [],
    this.fieldPins,
    this.firstPinKey,
    this.mapController,
    this.zoom = 13,
    this.showHeader = false,
    this.onBack,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final MapController _controller =
      widget.mapController ?? MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  late List<LatLng> _basePins = List<LatLng>.from(widget.pins);
  LatLng? _searchPin;
  bool _isSearching = false;

  List<LatLng> get _displayPins => [
        ..._basePins,
        if (_searchPin != null) _searchPin!,
      ];

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.pins, oldWidget.pins)) {
      _basePins = List<LatLng>.from(widget.pins);
      if (_searchPin != null && _basePins.contains(_searchPin)) {
        _searchPin = null;
      }
      _maybeFitToPins();
    }
  }

  @override
  void initState() {
    super.initState();
    // try to fit to pins on first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFitToPins());
  }

  void _maybeFitToPins() {
    final points = (widget.fieldPins != null && widget.fieldPins!.isNotEmpty)
        ? widget.fieldPins!.map((f) => f.location).toList()
        : List<LatLng>.from(widget.pins);

    if (points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (points.length == 1) {
          _controller.move(points.first, 14);
        } else {
          // approximate: move to center of bounds and use a default zoom
          final bounds = LatLngBounds.fromPoints(points);
          final center = LatLng((bounds.north + bounds.south) / 2,
              (bounds.west + bounds.east) / 2);
          _controller.move(center, 12);
        }
      } catch (_) {
        // controller might not be ready yet
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'MapPage.build: pins=${widget.pins.length}, fieldPins=${widget.fieldPins?.length ?? "null"}');
    final LatLng start =
        widget.pins.isNotEmpty ? widget.pins.first : LatLng(11.005, 124.607);

    final pins = _displayPins;

    final mapWidget = FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: start,
        initialZoom: widget.zoom,
        minZoom: 5,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.canemap',
        ),
        // build markers (cluster manually for better performance without extra dependency)
        MarkerLayer(
          markers: (() {
            final markers = <Marker>[];
            print(
                'MapPage: Building markers, fieldPins=${widget.fieldPins?.length ?? "null"}, pins=${pins.length}');

            if (widget.fieldPins != null && widget.fieldPins!.isNotEmpty) {
              print(
                  'MapPage: Using fieldPins for markers (${widget.fieldPins!.length} fields)');
              final fPins = widget.fieldPins!;
              final dist = Distance();
              final visited = List<bool>.filled(fPins.length, false);
              const clusterRadiusMeters = 2000.0; // 2km clustering radius

              for (int i = 0; i < fPins.length; i++) {
                if (visited[i]) continue;
                visited[i] = true;
                final base = fPins[i];
                final members = <FieldPin>[base];

                for (int j = i + 1; j < fPins.length; j++) {
                  if (visited[j]) continue;
                  final other = fPins[j];
                  final d = dist.distance(base.location, other.location);
                  if (d <= clusterRadiusMeters) {
                    visited[j] = true;
                    members.add(other);
                  }
                }

                if (members.length == 1) {
                  final f = members.first;
                  print(
                      'MapPage: Adding single marker for field "${f.fieldName}" at ${f.location}');
                  markers.add(Marker(
                    point: f.location,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showFieldDetails(i, f.location),
                      child: Icon(
                        Icons.location_pin,
                        key: i == 0 ? widget.firstPinKey : null,
                        color: _searchPin != null && f.location == _searchPin
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFF2F8F46),
                        size: 40,
                      ),
                    ),
                  ));
                } else {
                  // cluster marker
                  double lat = 0, lng = 0;
                  for (final m in members) {
                    lat += m.location.latitude;
                    lng += m.location.longitude;
                  }
                  lat /= members.length;
                  lng /= members.length;
                  final center = LatLng(lat, lng);

                  markers.add(Marker(
                    point: center,
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () {
                        // zoom in on cluster when tapped
                        _controller.move(center, 13);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F8F46),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          members.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ));
                }
              }
            } else {
              for (int i = 0; i < pins.length; i++) {
                markers.add(Marker(
                  point: pins[i],
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      _showFieldDetails(i, pins[i]);
                    },
                    child: Icon(
                      Icons.location_pin,
                      key: i == 0 ? widget.firstPinKey : null,
                      color: _searchPin != null && pins[i] == _searchPin
                          ? const Color(0xFF1E88E5)
                          : const Color(0xFF2F8F46),
                      size: 40,
                    ),
                  ),
                ));
              }
            }
            return markers;
          })(),
        ),
      ],
    );

    if (!widget.showHeader) return mapWidget;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed:
                        widget.onBack ?? () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF2F8F46),
                  ),
                ),
                const Text(
                  'Field Map',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F5E1F),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: mapWidget),
              Positioned(
                top: 24,
                left: 16,
                right: 16,
                child: _buildSearchBar(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        textInputAction: TextInputAction.search,
        onSubmitted: _handleSearch,
        decoration: InputDecoration(
          hintText: 'Search place or coordinates',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF2F8F46),
            size: 22,
          ),
          suffixIcon: _isSearching
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF2F8F46)),
                    ),
                  ),
                )
              : (_searchPin != null
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close, color: Color(0xFF2F8F46)),
                    )
                  : null),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _handleSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final Uri uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=1',
      );
      final response = await http
          .get(uri, headers: const {'User-Agent': 'CaneMap-App (flutter)'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.tryParse(data.first['lat']?.toString() ?? '');
          final lon = double.tryParse(data.first['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            final target = LatLng(lat, lon);
            _searchPin = target;
            _controller.move(target, 15);
            setState(() {});
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not found. Try a different search.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Unable to search right now. Please try again later.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _clearSearch() {
    setState(() {
      _searchPin = null;
      _isSearching = false;
      _searchCtrl.clear();
    });
  }

  String _markerMessageFor(LatLng pin, int index) {
    final isSearch = _searchPin != null && pin == _searchPin;
    final baseLabel = isSearch ? 'Search Result' : 'Field ${index + 1}';
    return '$baseLabel\nLat: ${pin.latitude.toStringAsFixed(4)}, Lng: ${pin.longitude.toStringAsFixed(4)}';
  }

  void _showFieldDetails(int index, LatLng pin) {
    final isSearchPin = _searchPin != null && pin == _searchPin;
    if (isSearchPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Search Result\nLat: ${pin.latitude.toStringAsFixed(4)}, Lng: ${pin.longitude.toStringAsFixed(4)}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // If field pins are available, show detailed information
    if (widget.fieldPins != null &&
        widget.fieldPins!.isNotEmpty &&
        index < widget.fieldPins!.length) {
      final field = widget.fieldPins![index];
      _showFieldDetailsBottomSheet(field);
    } else {
      // Fallback to simple message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _markerMessageFor(pin, index),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFieldDetailsBottomSheet(FieldPin field) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Field Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Field Name', field.fieldName),
              const SizedBox(height: 12),
              _buildDetailRow('Owner', field.applicantName),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Location', '${field.barangay}, ${field.municipality}'),
              const SizedBox(height: 12),
              _buildDetailRow('Coordinates',
                  '${field.latitude.toStringAsFixed(4)}, ${field.longitude.toStringAsFixed(4)}'),
              if (field.sizeHa != null && field.sizeHa!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Size', '${field.sizeHa} ha'),
              ],
              if (field.cropVariety != null &&
                  field.cropVariety!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Crop Variety', field.cropVariety ?? 'N/A'),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _controller.move(field.location, 15);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F8F46),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Center on Field',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
