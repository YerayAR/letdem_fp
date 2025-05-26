import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/dto/publish_event.dto.dart';
import 'package:letdem/features/activities/dto/publish_space.dto.dart';
import 'package:letdem/features/activities/dto/reserve_space.dto.dart';
import 'package:letdem/features/activities/repositories/activity.interface..dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/models/activities/activities_response.dto.dart';
import 'package:letdem/models/activities/activity.model.dart';
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

  Future takeSpace(String spaceID, TakeSpaceType t) async {
    ApiResponse res = await ApiService.sendRequest(
      endpoint: EndPoints.takeSpace(spaceID).copyWithDTO(TakeSpaceDTO(type: t)),
    );
    return res;
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
  Future publishSpace(PublishSpaceDTO dto, bool isFree) async {
    // ApiResponse res = await ApiService.sendRequest(
    //   endpoint: EndPoints.publishSpace.copyWithDTO(dto),
    // );

    ApiResponse res;

    if (isFree) {
      res = await ApiService.sendRequest(
        endpoint: EndPoints.publishSpaceFree.copyWithDTO(dto),
      );
    } else {
      res = await ApiService.sendRequest(
        endpoint: EndPoints.publishSpacePaid.copyWithDTO(dto),
      );
    }
    return null;
  }

  @override
  Future publishRoadEvent(PublishRoadEventDTO dto) async {
    ApiResponse res = await ApiService.sendRequest(
      endpoint: EndPoints.publishRoadEvent.copyWithDTO(dto),
    );
  }

  @override
  Future eventFeedback({required String eventID, required bool isThere}) {
    return ApiService.sendRequest(
      endpoint: EndPoints.eventFeedBack(eventID).copyWithDTO(
        EventFeedBackDTO(isThere: isThere),
      ),
    );
  }

  @override
  Future<ReservedSpacePayload> reserveSpace(
      {required String spaceID, required String paymentMethodID}) async {
    var res = await ApiService.sendRequest(
      endpoint: EndPoints.reserveSpace(spaceID).copyWithDTO(
        ReserveSpaceDTO(paymentMethodID: paymentMethodID),
      ),
    );

    return ReservedSpacePayload.fromJson(res.data);
  }

  @override
  Future confirmSpaceReservation(
      {required ConfirmationCodeDTO confirmationCode,
      required String spaceID}) async {
    return ApiService.sendRequest(
      endpoint:
          EndPoints.confirmReservation(spaceID).copyWithDTO(confirmationCode),
    );
  }
}
