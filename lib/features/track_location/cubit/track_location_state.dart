part of 'track_location_cubit.dart';

class TrackLocationState extends Equatable {
  final bool isConnected;
  final double? requesterLat;
  final double? requesterLng;
  final String? errorCode;

  const TrackLocationState({
    this.isConnected = false,
    this.requesterLat,
    this.requesterLng,
    this.errorCode,
  });

  @override
  List<Object?> get props => [
    isConnected,
    requesterLat,
    requesterLng,
    errorCode,
  ];

  TrackLocationState copyWith({
    bool? isConnected,
    double? requesterLat,
    double? requesterLng,
    String? errorCode,
  }) {
    return TrackLocationState(
      isConnected: isConnected ?? this.isConnected,
      requesterLat: requesterLat ?? this.requesterLat,
      requesterLng: requesterLng ?? this.requesterLng,
      errorCode: errorCode,
    );
  }
}
