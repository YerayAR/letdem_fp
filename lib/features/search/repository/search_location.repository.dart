import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/search/repository/search_location.interface.dart';
import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/api/api/models/response.model.dart';
import 'package:letdem/models/location/local_location.model.dart';

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
