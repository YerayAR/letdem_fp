import 'package:letdem/enums/LetDemLocationType.dart';
import 'package:letdem/models/map/coordinate.model.dart';

class LetDemLocation {
  final String id;
  final String name;

  final CoordinatesData coordinates;

  final LetDemLocationType type;

  LetDemLocation(
      {required this.id,
      required this.name,
      required this.coordinates,
      required this.type});

  factory LetDemLocation.fromMap(Map<String, dynamic> map) {
    return LetDemLocation(
      id: map['id'],
      name: map['location']['street_name'],
      coordinates: CoordinatesData.fromMap(map['location']['point']),
      type: LetDemLocationType.values.firstWhere(
          (e) => e.name.toString().toUpperCase() == map['type'].toUpperCase()),
    );
  }
}
