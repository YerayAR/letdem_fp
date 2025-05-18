part of 'activities_bloc.dart';

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
  final PublishSpaceType type;
  final DateTime expireAt;
  final String status;
  final bool isOwner;
  final String phone;
  final String confirmationCode;
  final String carPlateNumber;

  ReservedSpacePayload({
    required this.id,
    required this.price,
    required this.type,
    required this.expireAt,
    required this.status,
    required this.isOwner,
    required this.phone,
    required this.confirmationCode,
    required this.carPlateNumber,
  });

  factory ReservedSpacePayload.fromJson(Map<String, dynamic> json) {
    return ReservedSpacePayload(
      id: json['id'],
      price: double.parse(json['price'].toString()),
      type: getEnumFromText(json['type'], json['status']),
      expireAt: DateTime.parse(json['expires_at']),
      status: json['status'],
      isOwner: json['is_owner'],
      phone: json['phone'],
      confirmationCode: json['confirmation_code'].toString(),
      carPlateNumber: json['car_plate_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'type': type,
      'expires_at': expireAt.toIso8601String(),
      'status': status,
      'is_owner': isOwner,
      'phone': phone,
      'confirmation_code': confirmationCode,
      'car_plate_number': carPlateNumber,
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
