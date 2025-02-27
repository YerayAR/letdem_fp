import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';

abstract class IMapRepository {
  Future<MapNearbyPayload> getNearbyPlaces({
    required MapQueryParams queryParams,
  });
}
