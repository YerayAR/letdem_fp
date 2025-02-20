class MapQueryParams {
  MapQueryParams({
    this.options,
    this.currentPoint,
    this.radius,
    this.drivingMode,
    this.previousPoint,
  });

  final List<String>? options;
  final String? currentPoint;
  final int? radius;
  final bool? drivingMode;
  final String? previousPoint;
}
