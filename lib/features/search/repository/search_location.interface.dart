import 'package:letdem/features/search/dto/post_location.dto.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';

abstract class ILocationSearchRepository {
  Future<List<LetDemLocation>> getLocationList();
  Future<LetDemLocation> postLocation(PostLetDemoLocationDTO location);

  Future deleteLocation(LetDemLocationType deleteLocation);
}
