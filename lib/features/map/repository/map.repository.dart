import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';

class MapRepository extends IMapRepository {
  @override
  Future<MapNearbyPayload> getNearbyPlaces(
      {required MapQueryParams queryParams}) async {
    List<QParam> qParams = [];
    if (queryParams.options != null) {
      qParams.add(QParam(
        key: 'options',
        value: queryParams.options!.map((e) => e).join(','),
      ));
    }
    if (queryParams.radius != null) {
      qParams.add(QParam(
        key: 'radius',
        value: queryParams.radius.toString(),
      ));
    }
    if (queryParams.drivingMode != null) {
      qParams.add(QParam(
        key: 'driving-mode',
        value: queryParams.drivingMode.toString(),
      ));
    }

    if (queryParams.currentPoint != null) {
      qParams.add(QParam(
        key: 'current-point',
        value: queryParams.currentPoint.toString(),
      ));
    }

    EndPoints.getNearby.setParams(qParams);

    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getNearby,
    );
    return MapNearbyPayload.fromJson(response.data);
  }
}

abstract class IMapRepository {
  Future<MapNearbyPayload> getNearbyPlaces({
    required MapQueryParams queryParams,
  });
}
