import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/shimmers/location_bar.shimmer.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/LetDemLocationType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/presentation/widgets/search/add_location.widget.dart';
import 'package:letdem/features/activities/presentation/widgets/search/address_component.widget.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/service.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/location/local_location.model.dart';

import '../../../../../infrastructure/services/mapbox_search/models/cache.dart';
import '../../../../../infrastructure/services/res/navigator.dart';

class MapSearchBottomSheet extends StatefulWidget {
  const MapSearchBottomSheet({super.key});

  @override
  State<MapSearchBottomSheet> createState() => _MapSearchBottomSheetState();
}

class _MapSearchBottomSheetState extends State<MapSearchBottomSheet> {
  // ---------------------------------------------------------------------------
  // Properties & Controllers
  // ---------------------------------------------------------------------------
  late TextEditingController _controller;
  List<HerePlace> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
    context.read<SearchLocationBloc>().add(const GetLocationListEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Search Logic
  // ---------------------------------------------------------------------------
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() => _isSearching = true);
        try {
          // Usar el método de geocoding que garantiza ordenamiento por distancia
          var results =
              await HereSearchApiService().getGeocodingResults(query, context);

          // Si no hay resultados del geocoding, usar el método de autosuggestion
          if (results.isEmpty) {
            results =
                await HereSearchApiService().getLocationResults(query, context);
          }

          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        } catch (_) {
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        }
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  void _navigateToRoute(double lat, double lng, String streetName) {
    NavigatorHelper.to(NavigationMapScreen(
      destinationStreetName: streetName,
      hideToggle: false,
      latitude: lat,
      longitude: lng,
    ));
  }

  void _onLetDemLocationSelected(LetDemLocation location) {
    _navigateToRoute(location.coordinates.latitude,
        location.coordinates.longitude, location.name);
  }

  void _onHerePlaceSelected(HerePlace place) async {
    var fullName = '${place.title} ';

    if (place.latitude == null || place.longitude == null) {
      Toast.show("Location coordinates are not available.");
      return;
    }
    DatabaseHelper().savePlace(place);
    _navigateToRoute(place.latitude!, place.longitude!, fullName);
  }

  // ---------------------------------------------------------------------------
  // UI Builders
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.whereAreYouGoing,
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700)),
        IconButton(
          icon: Icon(CupertinoIcons.clear_circled_solid,
              color: AppColors.neutral400),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextInputField(
      isLoading: _isSearching,
      label: null,
      controller: _controller,
      onChanged: _onSearchChanged,
      showDeleteIcon: true,
      prefixIcon: IconlyLight.search,
      placeHolder: context.l10n.enterDestination,
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty || _controller.text.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: _searchResults
          .map((place) => SavedAddressComponent(
                place: place,
                onPlaceSelected: _onHerePlaceSelected,
                onApiPlaceSelected: _onLetDemLocationSelected,
                onHerePlaceDeleted: (_) {},
                onLetDemLocationDeleted: (_) {},
              ))
          .toList(),
    );
  }

  // TODO - Refactor this to avoid code duplication
  Widget _buildLocationTypeComponent({
    required LetDemLocationType locationType,
    required List<LetDemLocation> locations,
  }) {
    final filtered = locations.where((e) => e.type == locationType).toList();

    return Column(
      children: [
        SavedAddressComponent(
          locationType: locationType,
          apiPlace: filtered.isEmpty ? null : filtered.first,
          showDivider: filtered.isNotEmpty,
          onPlaceSelected: (place) {
            NavigatorHelper.pop();

            if (place.latitude == null || place.longitude == null) {
              Toast.show("Location coordinates are not available.");
              return;
            }

            context.read<SearchLocationBloc>().add(CreateLocationEvent(
                  isUpdating: filtered.isNotEmpty,
                  locationType: locationType,
                  name: place.title,
                  latitude: place.latitude ?? 0.0,
                  longitude: place.longitude ?? 0.0,
                ));
          },
          onApiPlaceSelected: _onLetDemLocationSelected,
          onLetDemLocationDeleted: (_) {
            context
                .read<SearchLocationBloc>()
                .add(DeleteLocationEvent(locationType: locationType));
          },
          onHerePlaceDeleted: (_) {},
          onEditLocationTriggered: () async {
            final HerePlace? place = await AppPopup.showBottomSheet(
              NavigatorHelper.navigatorKey.currentState!.context,
              AddLocationBottomSheet(
                title: context.l10n
                    .setLocation(toBeginningOfSentenceCase(locationType.name)!),
                onLocationSelected: (HerePlace loc) {
                  NavigatorHelper.pop(loc);
                },
              ),
            );

            if (place != null) {
              context.read<SearchLocationBloc>().add(CreateLocationEvent(
                    isUpdating: filtered.isNotEmpty,
                    locationType: locationType,
                    name: place.title,
                    latitude: place.latitude!,
                    longitude: place.longitude!,
                  ));
            }
          },
        ),
        Dimens.space(2),
      ],
    );
  }

  Widget _buildRecentLocationsSection(List<HerePlace> recentPlaces) {
    if (recentPlaces.isEmpty) return const SizedBox();
    return Column(
      children: [
        Row(
          children: [
            Text(context.l10n.recent,
                style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w500)),
            const Spacer(),
            GestureDetector(
              onTap: () => context
                  .read<SearchLocationBloc>()
                  .add(const ClearRecentLocationEvent()),
              child: Text(
                context.l10n.clearAll,
                style: Typo.mediumBody.copyWith(
                  color: AppColors.primary400,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        Dimens.space(2),
        Column(
          children: recentPlaces
              .map((place) => SavedAddressComponent(
                    place: place,
                    locationType: LetDemLocationType.other,
                    onPlaceSelected: _onHerePlaceSelected,
                    onHerePlaceDeleted: (place) {
                      context
                          .read<SearchLocationBloc>()
                          .add(DeleteRecentLocationEvent(place: place));
                    },
                    onLetDemLocationDeleted: (_) {},
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildContent(SearchLocationLoaded state) {
    if (_searchResults.isNotEmpty && _controller.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.favourites,
            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w500)),
        Dimens.space(2),
        _buildLocationTypeComponent(
            locationType: LetDemLocationType.home, locations: state.locations),
        _buildLocationTypeComponent(
            locationType: LetDemLocationType.work, locations: state.locations),
        Dimens.space(2),
        _buildRecentLocationsSection(state.recentPlaces),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Main Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Dimens.space(2),
            _buildSearchField(),
            Dimens.space(2),
            BlocBuilder<SearchLocationBloc, SearchLocationState>(
              builder: (context, state) {
                if (state is SearchLocationLoading) {
                  return const Column(
                    children: [
                      LocationBarShimmer(),
                      SizedBox(height: 15),
                      LocationBarShimmer(),
                      SizedBox(height: 15),
                      LocationBarShimmer(),
                    ],
                  );
                }
                if (state is SearchLocationLoaded) {
                  return Expanded(
                      child: ListView(children: [_buildContent(state)]));
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
