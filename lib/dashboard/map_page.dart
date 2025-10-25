import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final List<LatLng> pins;
  final GlobalKey? firstPinKey;
  final MapController? mapController;
  final double zoom;
  final bool showHeader;
  final VoidCallback? onBack;
  const MapPage({
    super.key,
    this.pins = const [],
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
  late final MapController _controller = widget.mapController ?? MapController();

  @override
  Widget build(BuildContext context) {
    final LatLng start = widget.pins.isNotEmpty
        ? widget.pins.first
        : LatLng(11.005, 124.607);

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
        MarkerLayer(
          markers: [
            for (int i = 0; i < widget.pins.length; i++)
              Marker(
                point: widget.pins[i],
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Field ${i + 1}\nLat: ${widget.pins[i].latitude.toStringAsFixed(4)}, Lng: ${widget.pins[i].longitude.toStringAsFixed(4)}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.location_pin,
                    key: i == 0 ? widget.firstPinKey : null,
                    color: const Color(0xFF2F8F46),
                    size: 40,
                  ),
                ),
              ),
          ],
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
                    onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
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
        Expanded(child: mapWidget),
      ],
    );
  }
}
