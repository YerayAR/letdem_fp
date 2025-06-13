extension TimeFormatter on int {
  String toFormattedTime() {
    if (this < 60) {
      return "$this seconds";
    } else if (this < 3600) {
      final minutes = (this / 60).floor();
      return "$minutes min";
    } else {
      final hours = (this / 3600).floor();
      final minutes = ((this % 3600) / 60).floor();
      return minutes > 0 ? "$hours h $minutes m" : "$hours h";
    }
  }

  String toFormattedDistance() {
    if (this >= 1000) {
      final km = (this / 1000).floor(); // remove decimal
      return "$km km";
    } else {
      return "$this m";
    }
  }
}
