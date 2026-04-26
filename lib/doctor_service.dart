import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor.dart';
import 'config.dart';

class DoctorService {
  static const String cacheKey = "cached_doctors_clinics";
  static const String lastSyncKey = "last_doctors_sync";

  /// Fetches nearby doctors and clinics from the Overpass API.
  static Future<List<Doctor>> getDoctors({
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
      print("Doctor API fetch failed: $e");
    }

    try {
      final cachedServices = await _loadFromCache();
      if (cachedServices.isNotEmpty) {
        return cachedServices;
      }
    } catch (e) {
      print("Doctor Cache load failed: $e");
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
      node["amenity"~"hospital|clinic|doctors|dentist|pharmacy"](around:$radiusMeters,$latitude,$longitude);
      way["amenity"~"hospital|clinic|doctors|dentist|pharmacy"](around:$radiusMeters,$latitude,$longitude);
      node["healthcare"~"hospital|clinic|doctor|dentist|pharmacy|laboratory"](around:$radiusMeters,$latitude,$longitude);
      way["healthcare"~"hospital|clinic|doctor|dentist|pharmacy|laboratory"](around:$radiusMeters,$latitude,$longitude);
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

    String name = tags['name'] ?? tags['name:en'] ?? tags['operator'] ?? 'Med Facility';
    String type = tags['amenity'] ?? tags['healthcare'] ?? 'Facility';
    type = type[0].toUpperCase() + type.substring(1);

    // Check for specific facilities
    bool hasEmergency = tags['emergency'] == 'yes';
    bool hasLab = tags['healthcare'] == 'laboratory' || tags['laboratory'] == 'yes';
    
    List<String> features = [];
    if (hasEmergency) features.add('🚨 Emergency Ward');
    if (hasLab) features.add('🩸 Blood Test/Lab');
    
    String featureString = features.isNotEmpty ? " • ${features.join(' ')}" : "";

    String address = tags['addr:full'] ??
        [tags['addr:housenumber'] ?? '', tags['addr:street'] ?? '', tags['addr:city'] ?? '']
            .where((part) => part.toString().trim().isNotEmpty)
            .join(', ');

    return Doctor(
      name: name,
      specialization: type + featureString,
      phone: tags['phone'] ?? tags['contact:phone'] ?? "Contact for details",
      address: address.isEmpty ? "Address not available" : address,
      latitude: lat,
      longitude: lon,
    );
  }

  static Future<void> _saveToCache(List<Doctor> doctors) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = doctors.map((d) => d.toJson()).toList();
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
    final String response = await rootBundle.loadString('assets/doctors.json');
    final List<dynamic> data = json.decode(response);
    return data.map((d) => Doctor.fromJson(d)).toList();
  }
}
