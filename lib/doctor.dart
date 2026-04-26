class Doctor {
  final String name;
  final String specialization;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  double? distance; // Distance from user in meters

  Doctor({
    required this.name,
    required this.specialization,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distance,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json['name'],
      specialization: json['specialization'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
