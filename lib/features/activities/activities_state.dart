import 'package:equatable/equatable.dart';
import 'package:letdem/features/activities/models/activity.model.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';

sealed class ActivitiesState extends Equatable {
  const ActivitiesState();
}

final class ActivitiesInitial extends ActivitiesState {
  @override
  List<Object> get props => [];
}

final class ActivitiesLoading extends ActivitiesState {
  @override
  List<Object?> get props => [];
}

final class ActivitiesLoaded extends ActivitiesState {
  final List<Activity> activities;

  const ActivitiesLoaded({required this.activities});

  @override
  List<Object?> get props => [activities];
}

final class ActivitiesPublished extends ActivitiesState {
  final int totalPointsEarned;

  const ActivitiesPublished({required this.totalPointsEarned});
  @override
  List<Object?> get props => [totalPointsEarned];
}

final class ActivitiesError extends ActivitiesState {
  final String error;

  const ActivitiesError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class SpaceReserved extends ActivitiesState {
  final ReservedSpacePayload spaceID;

  const SpaceReserved({required this.spaceID});

  @override
  List<Object?> get props => [spaceID];
}

class ReservedSpacePayload {
  final String id;
  final double price;
  final Space space;
  final DateTime expireAt;
  final String status;
  final bool isOwner;
  final String phone;
  final String confirmationCode;
  final String carPlateNumber;

  ReservedSpacePayload({
    required this.id,
    required this.price,
    required this.space,
    required this.expireAt,
    required this.status,
    required this.isOwner,
    required this.phone,
    required this.confirmationCode,
    required this.carPlateNumber,
  });

  factory ReservedSpacePayload.fromJson(Map<String, dynamic> json) {
    final spaceJson = json['space'] ?? {};
    return ReservedSpacePayload(
      id: json['id'],
      price: double.tryParse(spaceJson['price']?.toString() ?? '0') ?? 0,
      space: Space.fromJson(spaceJson),
      expireAt:
          DateTime.tryParse(spaceJson['expires_at'] ?? '') ?? DateTime.now(),
      isOwner: json['is_owner'] ?? false,
      phone: spaceJson['phone'] ?? '',
      status: json['status'] ?? '',
      confirmationCode: json['confirmation_code'].toString(),
      carPlateNumber: json['car_plate_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_owner': isOwner,
      'confirmation_code': confirmationCode,
      'car_plate_number': carPlateNumber,
      'space': space.toJson(),
    };
  }
}

String getTimeRemaining(DateTime expiresAt) {
  final now = DateTime.now();
  final difference = expiresAt.difference(now);

  if (difference.inMinutes <= 0) {
    return "Expired";
  } else {
    return "${difference.inMinutes} minutes left";
  }
}
