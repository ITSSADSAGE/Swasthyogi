import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doctor.dart';

class MapViewScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<Doctor> doctors;
  final List<Doctor> emergency;
  final int selectedTabIndex;

  const MapViewScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.doctors,
    required this.emergency,
    required this.selectedTabIndex,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();

  Future<void> _launchCall(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchDirections(double lat, double lon) async {
    final Uri uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lon");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showFacilityDetails(Doctor facility, Color color) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(
                      facility.specialization.toLowerCase().contains('police')
                          ? Icons.local_police
                          : facility.specialization.toLowerCase().contains('fire')
                              ? Icons.local_fire_department
                              : facility.specialization.toLowerCase().contains('hospital')
                                  ? Icons.local_hospital
                                  : Icons.place,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          facility.specialization,
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(facility.address, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(facility.phone, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchDirections(facility.latitude, facility.longitude);
                      },
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text("Directions", style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchCall(facility.phone);
                      },
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text("Call Now", style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

    // User location marker
    markers.add(
      Marker(
        point: LatLng(widget.latitude, widget.longitude),
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.selectedTabIndex == 0) {
      for (final doc in widget.doctors) {
        if (doc.latitude != 0.0 && doc.longitude != 0.0) {
          markers.add(_createServiceMarker(doc, Colors.teal, Icons.local_hospital));
        }
      }
    }

    if (widget.selectedTabIndex == 1) {
      for (final em in widget.emergency) {
        if (em.latitude != 0.0 && em.longitude != 0.0) {
          final icon = em.specialization.toLowerCase().contains('police')
              ? Icons.local_police
              : em.specialization.toLowerCase().contains('fire')
                  ? Icons.local_fire_department
                  : Icons.local_hospital;
          markers.add(_createServiceMarker(em, Colors.red, icon));
        }
      }
    }

    return markers;
  }

  Marker _createServiceMarker(Doctor service, Color color, IconData iconData) {
    return Marker(
      point: LatLng(service.latitude, service.longitude),
      width: 140,
      height: 90,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => _showFacilityDetails(service, color),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMarkerIcon(iconData, color),
            _buildCleanLabel(service.name, color),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildCleanLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: const [
            Shadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(widget.latitude, widget.longitude),
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.swasthyogi.app',
        ),
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }
}