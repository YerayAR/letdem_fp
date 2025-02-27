class CoordinatesData {
  final double latitude;
  final double longitude;

  CoordinatesData({required this.latitude, required this.longitude});

  factory CoordinatesData.fromMap(Map<String, dynamic> map) {
    return CoordinatesData(
      latitude: map['lat'],
      longitude: map['lng'],
    );
  }
}
