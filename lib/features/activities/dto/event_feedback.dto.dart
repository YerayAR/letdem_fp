import 'package:letdem/infrastructure/api/api/models/endpoint.dart';

class EventFeedBackDTO extends DTO {
  final bool isThere;

  EventFeedBackDTO({required this.isThere});

  @override
  Map<String, dynamic> toMap() {
    return {
      "type": isThere ? "IS_THERE" : "NOT_THERE",
    };
  }
}
