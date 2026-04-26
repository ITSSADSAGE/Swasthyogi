/// Configuration for OpenStreetMap Overpass API
class AppConfig {
  // Overpass API is free and doesn't require an API key
  static const String overpassApiUrl = "https://overpass-api.de/api/interpreter";
  
  // Search parameters
  static const int defaultSearchRadiusMeters = 10000; // 10km
  static const String searchKeywords = "hospital|clinic|doctors|health|ambulance|police|fire_station|emergency|shelter";
  
  // Cache settings
  static const int cacheExpiryHours = 24;
  
  // Attribution
  static const String osmAttribution = "Data © OpenStreetMap contributors";
}
