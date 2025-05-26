import 'package:letdem/enums/LetDemLocationType.dart';
import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

class PostLetDemoLocationDTO extends DTO {
  final String name;

  final LetDemLocationType type;
  final double latitude;
  final double longitude;

  PostLetDemoLocationDTO({
    required this.name,
    required this.latitude,
    required this.type,
    required this.longitude,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'address': {
        'street_name': name,
        'lat': latitude,
        'lng': longitude,
      }
    };
  }
}
