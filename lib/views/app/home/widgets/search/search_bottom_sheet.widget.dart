import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/enums/LetDemLocationType.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/models/location/local_location.model.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/mapbox_search/models/cache.dart';
import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/home/widgets/search/add_location.widget.dart';
import 'package:letdem/views/app/home/widgets/search/address_component.widget.dart';
import 'package:letdem/views/app/maps/route.view.dart';
import 'package:shimmer/shimmer.dart';

class MapSearchBottomSheet extends StatefulWidget {
  const MapSearchBottomSheet({super.key});

  @override
  State<MapSearchBottomSheet> createState() => _MapSearchBottomSheetState();
}

class _MapSearchBottomSheetState extends State<MapSearchBottomSheet> {
  // Properties
  late TextEditingController _controller;
  List<MapBoxPlace> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
    context.read<SearchLocationBloc>().add(const GetLocationListEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Private methods
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() {
          _isSearching = true;
        });

        try {
          var results =
              await MapboxSearchApiService().getLocationResults(query, context);
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        } catch (e) {
          setState(() {
            _isSearching = false;
            _searchResults = [];
          });
        }
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  void _navigateToRoute(double lat, double lng, String streetName) {
    NavigatorHelper.to(
      TrafficRouteLineExample(
        streetName: streetName,
        hideToggle: false,
        lat: lat,
        lng: lng,
      ),
    );
  }

  void _onLetDemLocationSelected(LetDemLocation location) {
    _navigateToRoute(
      location.coordinates.latitude,
      location.coordinates.longitude,
      location.name,
    );
  }

  void _onMapBoxPlaceSelected(MapBoxPlace place) async {
    var val = '${place.name} ${place.placeFormatted} ';
    // Save place to local database
    DatabaseHelper().savePlace(place);

    // Get coordinates and navigate
    var coordinates = await MapboxService.getLatLng(val);
    if (coordinates != null) {
      _navigateToRoute(
        coordinates.latitude,
        coordinates.longitude,
        val,
      );
    }
  }

  // UI Components
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Where are you going to?",
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        IconButton(
          icon: Icon(
            CupertinoIcons.clear_circled_solid,
            color: AppColors.neutral400,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextInputField(
      isLoading: _isSearching,
      label: null,
      onChanged: _onSearchChanged,
      controller: _controller,
      showDeleteIcon: true,
      prefixIcon: IconlyLight.search,
      placeHolder: 'Enter destination',
    );
  }

  Widget _buildLocationTypeComponent({
    required LetDemLocationType locationType,
    required List<LetDemLocation> locations,
  }) {
    final filteredLocations =
        locations.where((e) => e.type == locationType).toList();

    if (filteredLocations.isEmpty) {
      return Column(
        children: [
          SavedAddressComponent(
            locationType: locationType,
            showDivider: false,
            onEditLocationTriggered: () {
              Toast.show("editing");
              // final place =
              //     await AppPopup.showBottomSheet(
              //   NavigatorHelper.navigatorKey!
              //       .currentState!.context,
              //   AddLocationBottomSheet(
              //     title:
              //     "${toBeginningOfSentenceCase(locationType.name)} Location",
              //     onLocationSelected:
              //         (MapBoxPlace place) {
              //       print(place.toJson());
              //       Navigator.pop(context, place);
              //     },
              //   ),
              // );
            },
            onApiPlaceSelected: _onLetDemLocationSelected,
            onPlaceSelected: (MapBoxPlace p) async {
              Toast.show("This stupid thing triggered ");
              var val = '${p.name} ${p.placeFormatted} ';
              var latLng = await MapboxService.getLatLng(val);

              context.read<SearchLocationBloc>().add(
                    CreateLocationEvent(
                      isUpdating: false,
                      locationType: locationType,
                      name: val,
                      latitude: latLng!.latitude,
                      longitude: latLng.longitude,
                    ),
                  );
            },
            onMapBoxPlaceDeleted: (_) {},
            onLetDemLocationDeleted: (_) {},
          ),
          Dimens.space(2),
        ],
      );
    } else {
      return Column(
        children: filteredLocations
            .map(
              (e) => SavedAddressComponent(
                locationType: locationType,
                showDivider: true,
                apiPlace: e,
                onEditLocationTriggered: () async {
                  MapBoxPlace? p = await AppPopup.showBottomSheet(
                    NavigatorHelper.navigatorKey!.currentState!.context,
                    AddLocationBottomSheet(
                      title:
                          "${toBeginningOfSentenceCase(locationType.name)} Location",
                      onLocationSelected: (MapBoxPlace place) {
                        print(place.toJson());
                        Navigator.pop(context, place);
                      },
                    ),
                  );

                  if (p != null) {
                    var val = '${p.name} ${p.placeFormatted} ';
                    var latLng = await MapboxService.getLatLng(val);

                    context.read<SearchLocationBloc>().add(
                          CreateLocationEvent(
                            isUpdating: true,
                            locationType: locationType,
                            name: val,
                            latitude: latLng!.latitude,
                            longitude: latLng.longitude,
                          ),
                        );
                  }
                },
                onApiPlaceSelected: _onLetDemLocationSelected,
                onPlaceSelected: (_) {},
                onMapBoxPlaceDeleted: (_) {},
                onLetDemLocationDeleted: (_) {
                  context.read<SearchLocationBloc>().add(
                        DeleteLocationEvent(locationType: locationType),
                      );
                },
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildRecentLocationsSection(List<MapBoxPlace> recentPlaces) {
    if (recentPlaces.isEmpty) return const SizedBox();
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Recent',
              style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                context
                    .read<SearchLocationBloc>()
                    .add(const ClearRecentLocationEvent());
              },
              child: Text(
                'Clear all',
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
              .map(
                (place) => SavedAddressComponent(
                  place: place,
                  locationType: LetDemLocationType.other,
                  onPlaceSelected: _onMapBoxPlaceSelected,
                  onMapBoxPlaceDeleted: (place) {
                    context.read<SearchLocationBloc>().add(
                          DeleteRecentLocationEvent(place: place),
                        );
                  },
                  onLetDemLocationDeleted: (_) {},
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty || _controller.text.isEmpty)
      return const SizedBox();

    return Column(
      children: _searchResults
          .map(
            (place) => SavedAddressComponent(
              place: place,
              onPlaceSelected: _onMapBoxPlaceSelected,
              onApiPlaceSelected: _onLetDemLocationSelected,
              onMapBoxPlaceDeleted: (_) {},
              onLetDemLocationDeleted: (_) {},
            ),
          )
          .toList(),
    );
  }

  Widget _buildContent(SearchLocationLoaded state) {
    if (_searchResults.isNotEmpty && _controller.text.isNotEmpty) {
      return _buildSearchResults();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favourites',
          style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w500),
        ),
        Dimens.space(2),
        _buildLocationTypeComponent(
          locationType: LetDemLocationType.home,
          locations: state.locations,
        ),
        _buildLocationTypeComponent(
          locationType: LetDemLocationType.work,
          locations: state.locations,
        ),
        Dimens.space(2),
        _buildRecentLocationsSection(state.recentPlaces),
      ],
    );
  }

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

            // Main content section
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
                    child: ListView(
                      children: [_buildContent(state)],
                    ),
                  );
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

class LocationBarShimmer extends StatelessWidget {
  const LocationBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Circle avatar shimmer
        ClipRRect(
          borderRadius: BorderRadius.circular(1500),
          child: SizedBox(
            height: 60.0,
            width: 60.0,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200]!.withOpacity(0.2),
              highlightColor: Colors.grey[50]!,
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
        ),
        Dimens.space(1),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              height: 60.0,
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!.withOpacity(0.2),
                highlightColor: Colors.grey[50]!,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
