import 'package:letdem/enums/CarTagType.dart';
import 'package:letdem/services/api/models/endpoint.dart';

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
