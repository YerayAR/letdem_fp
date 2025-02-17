import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/search/repository/search_location.interface.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

class SearchLocationRepository extends ILocationSearchRepository {
  @override
  Future<List<LetDemLocation>> getLocationList() async {
    ApiResponse response =
        await ApiService.sendRequest(endpoint: EndPoints.locationListEndpoint);

    return (response.data['data'] as List)
        .map((e) => LetDemLocation.fromMap(e))
        .toList();
  }

  @override
  Future<LetDemLocation> postLocation(PostLetDemoLocationDTO location) async {
    ApiResponse response = await ApiService.sendRequest(
        endpoint: location.type == LetDemLocationType.work
            ? EndPoints.addWorkLocation.copyWithDTO(location)
            : EndPoints.addHomeLocation.copyWithDTO(location));

    return LetDemLocation.fromMap(response.data);
  }

  @override
  Future deleteLocation(LetDemLocationType deleteLocation) async {
    await ApiService.sendRequest(
        endpoint: deleteLocation == LetDemLocationType.work
            ? EndPoints.deleteWorkLocation
            : EndPoints.deleteHomeLocation);
  }
}

enum LetDemLocationType { work, home, other }

class LetDemLocation {
  final String id;
  final String name;

  final CoordinatesData coordinates;

  final LetDemLocationType type;

  LetDemLocation(
      {required this.id,
      required this.name,
      required this.coordinates,
      required this.type});

  factory LetDemLocation.fromMap(Map<String, dynamic> map) {
    return LetDemLocation(
      id: map['id'],
      name: map['location']['street_name'],
      coordinates: CoordinatesData.fromMap(map['location']['point']),
      type: LetDemLocationType.values.firstWhere(
          (e) => e.name.toString().toUpperCase() == map['type'].toUpperCase()),
    );
  }
}

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
