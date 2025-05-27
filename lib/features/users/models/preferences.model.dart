class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;

  NotificationPreferences({
    required this.pushNotifications,
    required this.emailNotifications,
  });

  factory NotificationPreferences.fromJSON(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushNotifications: json['push'],
      emailNotifications: json['email'],
    );
  }

  toJSON() {
    return {
      'push': pushNotifications,
      'email': emailNotifications,
    };
  }

  bool getPreference(String preferenceKey) {
    return toJSON()[preferenceKey];
  }
}
