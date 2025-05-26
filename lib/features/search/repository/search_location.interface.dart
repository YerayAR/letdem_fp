import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/models/location/local_location.model.dart';

abstract class ILocationSearchRepository {
  Future<List<LetDemLocation>> getLocationList();
  Future<LetDemLocation> postLocation(PostLetDemoLocationDTO location);

  Future deleteLocation(LetDemLocationType deleteLocation);
}
