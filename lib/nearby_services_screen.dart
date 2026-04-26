import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doctor.dart';
import 'doctor_service.dart';
import 'emergency_service.dart';
import 'config.dart';

import 'map_view_screen.dart';

class NearbyServicesScreen extends StatefulWidget {
  final String language;
  const NearbyServicesScreen({super.key, required this.language});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Doctor> doctors = [];
  List<Doctor> emergency = [];
  bool isLoading = true;
  Position? userPosition;
  int _currentTabIndex = 0;
  bool isMapView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
    _loadAllServices();
  }

  Future<void> _loadAllServices() async {
    setState(() => isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      userPosition = position;

      final docs = await DoctorService.getDoctors(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      final emergencies = await EmergencyService.getEmergencyServices(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _calculateDistances(docs, position);
      _calculateDistances(emergencies, position);

      if (mounted) {
        setState(() {
          doctors = docs;
          emergency = emergencies;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading services: $e");
      final docs = await DoctorService.getDoctors(latitude: 0, longitude: 0);
      final emergencies = await EmergencyService.getEmergencyServices(latitude: 0, longitude: 0);

      if (mounted) {
        setState(() {
          doctors = docs;
          emergency = emergencies;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not load location-based data: $e")),
        );
      }
    }
  }

  void _calculateDistances(List<Doctor> list, Position pos) {
    for (final item in list) {
      item.distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        item.latitude,
        item.longitude,
      );
    }
    list.sort((a, b) => (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));
  }

  String _formatDistance(double? distanceMeters) {
    if (distanceMeters == null) return '';
    if (distanceMeters < 1000) return '${distanceMeters.toStringAsFixed(0)} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _launchDirections(double lat, double lon) async {
    final Uri uri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lon");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchCall(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.language == "Hindi" || widget.language == "हिंदी";
    final isMarathi = widget.language == "Marathi" || widget.language == "मराठी";

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "जवळच्या सेवा" : (isHindi ? "नज़दीकी सेवाएँ" : "Nearby Facilities")),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.list, color: !isMapView ? Colors.teal : Colors.grey),
                  onPressed: () => setState(() => isMapView = false),
                ),
                IconButton(
                  icon: Icon(Icons.map, color: isMapView ? Colors.teal : Colors.grey),
                  onPressed: () => setState(() => isMapView = true),
                ),
              ],
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: isMarathi ? "वैद्यकीय सुविधा" : (isHindi ? "चिकित्सा सुविधा" : "Med Facility")),
            Tab(text: isMarathi ? "आणीबाणी" : (isHindi ? "आपातकालीन" : "Emergency")),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isMapView && userPosition != null
              ? MapViewScreen(
                  latitude: userPosition!.latitude,
                  longitude: userPosition!.longitude,
                  doctors: doctors,
                  emergency: emergency,
                  selectedTabIndex: _currentTabIndex,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(doctors, Colors.teal),
                    _buildList(emergency, Colors.red),
                  ],
                ),
    );
  }

  Widget _buildList(List<Doctor> list, Color color) {
    if (list.isEmpty) return const Center(child: Text("No services found"));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                item.specialization.contains('Police')
                    ? Icons.local_police
                    : item.specialization.contains('Fire')
                        ? Icons.fire_truck
                        : item.specialization.contains('Hospital')
                            ? Icons.local_hospital
                            : Icons.person,
                color: color,
              ),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.specialization, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                Text(item.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (item.distance != null)
                  Text(_formatDistance(item.distance), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.directions, color: Colors.blue),
                  onPressed: () => _launchDirections(item.latitude, item.longitude),
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _launchCall(item.phone),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}