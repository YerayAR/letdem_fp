import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/features/activities/models/activity.model.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';

abstract class IActivityRepository {
  Future<void> addActivity(Activity activity);

  Future confirmSpaceReservation({
    required String spaceID,
    required ConfirmationCodeDTO confirmationCode,
  });

  Future deleteSpace(String spaceID);

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
