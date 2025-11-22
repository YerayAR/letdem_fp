import '../../../infrastructure/api/api/models/endpoint.dart';

class ExtendTimeSpaceDTO extends DTO {
  final int time;

  ExtendTimeSpaceDTO({required this.time});

  @override
  Map<String, dynamic> toMap() {
    return {'time_to_wait': time};
  }
}
