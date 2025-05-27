class Activity {
  final String id;
  final String type;
  final String action;
  final int points;
  final DateTime created;

  Activity({
    required this.id,
    required this.type,
    required this.action,
    required this.points,
    required this.created,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      action: json['action'],
      points: json['points'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'action': action,
      'points': points,
      'created': created.toIso8601String(),
    };
  }
}
