import 'package:letdem/models/activities/activity.model.dart';

class ActivityResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Activity> results;

  ActivityResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((e) => Activity.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
