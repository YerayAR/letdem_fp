import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';

abstract class IMapRepository {
  Future<MapNearbyPayload> getNearbyPlaces({
    required MapQueryParams queryParams,
  });
}
