import 'package:letdem/core/enums/CarTagType.dart';
import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

class CreateCartDTO extends DTO {
  final String brand;
  final String registrationNumber;
  final CarTagType tagType;

  CreateCartDTO({
    required this.brand,
    required this.registrationNumber,
    required this.tagType,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': brand,
      'plate_number': registrationNumber,
      'label': tagType.name.toUpperCase(),
    };
  }
}
