import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

enum TakeSpaceType { TAKE_IT, IN_USE, NOT_USEFUL, PROHIBITED }

class TakeSpaceDTO extends DTO {
  final TakeSpaceType type;

  TakeSpaceDTO({required this.type});

  Map<String, dynamic> toJson() {
    return {
      "type": type.name.toUpperCase(),
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": type.name.toUpperCase(),
    };
  }
}
