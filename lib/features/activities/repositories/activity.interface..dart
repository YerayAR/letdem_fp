import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/models/activities/activity.model.dart';

abstract class IActivityRepository {
  Future<Activity> getActivity(String id);
  Future<void> addActivity(Activity activity);
  Future<void> updateActivity(Activity activity);
  Future<void> deleteActivity(String id);

  Future confirmSpaceReservation({
    required String spaceID,
    required ConfirmationCodeDTO confirmationCode,
  });

  Future publishSpace(PublishSpaceDTO dto, bool isFree);

  Future<ReservedSpacePayload> reserveSpace({
    required String spaceID,
    required String paymentMethodID,
  });

  Future publishRoadEvent(PublishRoadEventDTO dto);

  Future eventFeedback({
    required String eventID,
    required bool isThere,
  });
}
