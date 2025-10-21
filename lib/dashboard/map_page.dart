import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final List<LatLng> pins;
  final GlobalKey? firstPinKey;
  const MapPage({super.key, this.pins = const [], this.firstPinKey});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  void _centerMap() {
    final LatLng center = widget.pins.isNotEmpty
        ? widget.pins.first
        : LatLng(11.005, 124.607);
    _mapController.move(center, 13);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng start = widget.pins.isNotEmpty
        ? widget.pins.first
        : LatLng(11.005, 124.607);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F3),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: start,
              initialZoom: 13,
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
          ),

          // Top Controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F3),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF2F8F46),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ormoc City, Philippines',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F8F46).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${widget.pins.length} fields',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F8F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side Controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // Zoom In Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF2F8F46),
                      size: 20,
                    ),
                    onPressed: _zoomIn,
                    tooltip: 'Zoom In',
                  ),
                ),
                const SizedBox(height: 8),

                // Zoom Out Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Color(0xFF2F8F46),
                      size: 20,
                    ),
                    onPressed: _zoomOut,
                    tooltip: 'Zoom Out',
                  ),
                ),
                const SizedBox(height: 8),

                // Center Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: Color(0xFF2F8F46),
                      size: 20,
                    ),
                    onPressed: _centerMap,
                    tooltip: 'Center Map',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
