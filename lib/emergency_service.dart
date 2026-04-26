import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor.dart'; // Using the same data model for simplicity
import 'config.dart';

class EmergencyService {
  static const String cacheKey = "cached_emergency_services";
  static const String lastSyncKey = "last_emergency_sync";

  /// Fetches nearby hospitals, police, and fire stations from the Overpass API.
  static Future<List<Doctor>> getEmergencyServices({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final services = await _fetchFromApi(latitude, longitude, radiusKm);
      if (services.isNotEmpty) {
        await _saveToCache(services);
        return services;
      }
    } catch (e) {
      print("Emergency API fetch failed: $e");
    }

    try {
      final cachedServices = await _loadFromCache();
      if (cachedServices.isNotEmpty) {
        return cachedServices;
      }
    } catch (e) {
      print("Emergency Cache load failed: $e");
    }

    return await _loadFromBundledJson();
  }

  static final List<String> _mirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.osm.ch/api/interpreter',
  ];

  static Future<List<Doctor>> _fetchFromApi(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final radiusMeters = (radiusKm * 1000).toInt();

    final String query = """
    [out:json][timeout:30];
    (
      node["amenity"~"police|fire_station"](around:$radiusMeters,$latitude,$longitude);
      way["amenity"~"police|fire_station"](around:$radiusMeters,$latitude,$longitude);
      node["emergency"~"yes|emergency_ward|ambulance_station"](around:$radiusMeters,$latitude,$longitude);
      way["emergency"~"yes|emergency_ward|ambulance_station"](around:$radiusMeters,$latitude,$longitude);
      node["amenity"="hospital"]["emergency"="yes"](around:$radiusMeters,$latitude,$longitude);
      way["amenity"="hospital"]["emergency"="yes"](around:$radiusMeters,$latitude,$longitude);
    );
    out center;
    """;

    for (String mirror in _mirrors) {
      try {
        final response = await http.post(
          Uri.parse(mirror),
          headers: {
            'User-Agent': 'SwasthyogiApp/1.0 (https://swasthyogi.app; contact@swasthyogi.app)',
          },
          body: query,
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> elements = data['elements'] ?? [];
          return elements.map((element) => _parseOsmElement(element)).toList();
        } else if (response.statusCode == 429) {
          print("Mirror $mirror rate limited (429), trying next...");
          continue;
        } else {
          print("Mirror $mirror failed: ${response.statusCode}");
        }
      } catch (e) {
        print("Error connecting to mirror $mirror: $e");
        continue;
      }
    }

    throw Exception("All Overpass mirrors failed or were rate limited.");
  }

  static Doctor _parseOsmElement(Map<String, dynamic> element) {
    final tags = element['tags'] ?? {};
    double lat = element['lat'] ?? element['center']?['lat'] ?? 0.0;
    double lon = element['lon'] ?? element['center']?['lon'] ?? 0.0;

    String name = tags['name'] ?? tags['operator'] ?? 'Emergency Service';
    String type = tags['amenity'] ?? tags['emergency'] ?? 'Emergency';
    type = type[0].toUpperCase() + type.substring(1).replaceAll('_', ' ');

    if (type == 'Hospital') {
      type += ' (Emergency Ward)';
    }

    String address = tags['addr:full'] ??
        [tags['addr:housenumber'] ?? '', tags['addr:street'] ?? '', tags['addr:city'] ?? '']
            .where((part) => part.toString().trim().isNotEmpty)
            .join(', ');

    return Doctor(
      name: name,
      specialization: type,
      phone: tags['phone'] ?? tags['contact:phone'] ?? "112 (Universal Emergency)",
      address: address.isEmpty ? "Address not available" : address,
      latitude: lat,
      longitude: lon,
    );
  }

  static Future<void> _saveToCache(List<Doctor> services) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = services.map((s) => s.toJson()).toList();
    await prefs.setString(cacheKey, json.encode(jsonList));
    await prefs.setInt(lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<Doctor>> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);
    if (cachedData == null) return [];
    final List<dynamic> data = json.decode(cachedData);
    return data.map((d) => Doctor.fromJson(d)).toList();
  }

  static Future<List<Doctor>> _loadFromBundledJson() async {
    try {
      final String response = await rootBundle.loadString('assets/emergency_services.json');
      final List<dynamic> data = json.decode(response);
      return data.map((d) => Doctor.fromJson(d)).toList();
    } catch (e) {
      print("Bundled emergency JSON not found or invalid: $e");
      return [];
    }
  }
}
