extension TimeFormatter on int {
  // String toFormattedTime() {
  //   int minutes = this ~/ 60;
  //   int seconds = this % 60;
  //
  //   String minutesStr = minutes.toString().padLeft(2, '0');
  //   String secondsStr = seconds.toString().padLeft(2, '0');
  //
  //   return "$minutesStr min".startsWith("00")
  //       ? "$secondsStr sec"
  //       : "$minutesStr min";
  // }

//   format meters to km
  String toFormattedDistance() {
    if (this >= 1000) {
      return "${(this / 1000).toStringAsFixed(1)} km";
    } else {
      return "$this m";
    }
  }
}
