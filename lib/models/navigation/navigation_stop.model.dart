import 'package:here_sdk/core.dart' as HERE;

enum StopStatus { pending, active, completed }

class NavigationStop {
  final String id;
  final String streetName;
  final HERE.GeoCoordinates coordinates;
  final StopStatus status;
  final int orderIndex;

  NavigationStop({
    required this.id,
    required this.streetName,
    required this.coordinates,
    required this.status,
    required this.orderIndex,
  });

  NavigationStop copyWith({
    String? id,
    String? streetName,
    HERE.GeoCoordinates? coordinates,
    StopStatus? status,
    int? orderIndex,
  }) {
    return NavigationStop(
      id: id ?? this.id,
      streetName: streetName ?? this.streetName,
      coordinates: coordinates ?? this.coordinates,
      status: status ?? this.status,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
