import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/models/activities/activity.model.dart';

abstract class IActivityRepository {
  Future<Activity> getActivity(String id);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id);

  Future publishSpace(PublishSpaceDTO dto);

  Future publishRoadEvent(PublishRoadEventDTO dto);
}
