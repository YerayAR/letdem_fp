import 'dart:async';

import 'package:here_sdk/core.dart';
import 'package:here_sdk/search.dart';

/// Servicio de dominio para buscar puntos de carga EV con HERE SearchEngine.
class EvChargingSearchService {
  final SearchEngine _searchEngine;

  EvChargingSearchService(this._searchEngine);

  Future<List<Place>> searchNearbyEvChargers(
    GeoCoordinates center,
    int radiusInMeters,
  ) async {
    // Definir área alrededor de la posición actual.
    final area = CategoryQueryArea.withCircle(
      center,
      GeoCircle(center, radiusInMeters.toDouble()),
    );

    final query = CategoryQuery.withCategoryInArea(
      PlaceCategory(PlaceCategory.businessAndServicesEvChargingStation),
      area,
    );

    final options = SearchOptions()
      ..languageCode = LanguageCode.esEs
      ..maxItems = 20;

    final completer = Completer<List<Place>>();

    _searchEngine.searchByCategory(
      query,
      options,
      (SearchError? error, List<Place>? places) {
        // Log básico para depuración
        // ignore: avoid_print
        print('[EV_SEARCH] error=$error, count=${places?.length ?? 0}');
        if (error != null) {
          completer.completeError(error);
        } else {
          completer.complete(places ?? <Place>[]);
        }
      },
    );

    return completer.future;
  }
}
