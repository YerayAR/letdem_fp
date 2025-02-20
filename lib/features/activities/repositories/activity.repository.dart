import 'package:letdem/features/activities/repositories/activity.interface..dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

class ActivityRepository extends IActivityRepository {
  @override
  Future<void> addActivity(Activity activity) {
    // TODO: implement addActivity
    throw UnimplementedError();
  }

  @override
  Future<void> deleteActivity(String id) {
    // TODO: implement deleteActivity
    throw UnimplementedError();
  }

  @override
  Future<ActivityResponse> getActivities() async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getContributions,
    );
    return ActivityResponse.fromJson(response.data);
    // return response.data.map((e) => Activity.fromMap(e)).toList();
  }

  @override
  Future<Activity> getActivity(String id) {
    // TODO: implement getActivity
    throw UnimplementedError();
  }

  @override
  Future<void> updateActivity(Activity activity) {
    // TODO: implement updateActivity
    throw UnimplementedError();
  }

  @override
  Future publishSpace(PublishSpaceDTO dto) async {
    return await ApiService.sendRequest(
      endpoint: EndPoints.publishSpace.copyWithDTO(dto),
    );
  }

  @override
  Future publishRoadEvent(PublishRoadEventDTO dto) async {
    return await ApiService.sendRequest(
      endpoint: EndPoints.publishRoadEvent.copyWithDTO(dto),
    );
  }
}
