import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/enums/LetDemLocationType.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/main.dart';
import 'package:letdem/models/location/local_location.model.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/mapbox_search/models/cache.dart';
import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/widgets/search/address_component.widget.dart';
import 'package:shimmer/shimmer.dart';

class MapSearchBottomSheet extends StatefulWidget {
  const MapSearchBottomSheet({super.key});

  @override
  State<MapSearchBottomSheet> createState() => _MapSearchBottomSheetState();
}

class _MapSearchBottomSheetState extends State<MapSearchBottomSheet> {
  List<MapBoxPlace> _searchResults = [];
  Timer? _debounce;
  bool isSearching = false;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
    context.read<SearchLocationBloc>().add(const GetLocationListEvent());
    super.initState();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() {
          isSearching = true;
        });
        var results = await MapboxSearchApiService().getLocationResults(query);
        print(results.first.toJson());
        setState(() {
          _searchResults = results;
          isSearching = false;
        });
      }
    });
  }

  late TextEditingController _controller;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
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
            // Top Row with title and close button
            Row(
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            Dimens.space(2),

            // Search Input Field
            TextInputField(
              isLoading: isSearching,
              label: null,
              onChanged: _onSearchChanged,
              controller: _controller,
              prefixIcon: IconlyLight.search,
              placeHolder: 'Enter destination',
            ),
            Dimens.space(2),

            // Favourites Section
            if (_searchResults.isEmpty) ...[
              Text(
                'Favourites',
                style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w500),
              ),
              Dimens.space(2),
            ],

            // List of search results or saved addresses
            BlocBuilder<SearchLocationBloc, SearchLocationState>(
              builder: (context, state) {
                if (state is SearchLocationLoading) {
                  return const Column(
                    spacing: 15,
                    children: [
                      LocationBarShimmer(),
                      LocationBarShimmer(),
                      LocationBarShimmer(),
                    ],
                  );
                }
                return state is SearchLocationLoaded
                    ? Expanded(
                        child: ListView(
                          children: _searchResults.isNotEmpty &&
                                  _controller.text.isNotEmpty
                              ? _searchResults
                                  .map((e) => SavedAddressComponent(
                                        onMapBoxPlaceDeleted:
                                            (MapBoxPlace place) {},
                                        onLetDemLocationDeleted:
                                            (LetDemLocation location) {},
                                        place: e,
                                        onPlaceSelected: (MapBoxPlace p) async {
                                          DatabaseHelper().savePlace(p);

                                          var c = await MapboxService.getLatLng(
                                              p.fullAddress);
                                          NavigatorHelper.to(
                                              TrafficRouteLineExample(
                                            lat: c!.latitude,
                                            lng: c.longitude,
                                          ));
                                        },
                                      ))
                                  .toList()
                              : [
                                  SizedBox(
                                      child: state.locations
                                              .where(
                                                (e) =>
                                                    e.type ==
                                                    LetDemLocationType.home,
                                              )
                                              .isEmpty
                                          ? Column(
                                              children: [
                                                SavedAddressComponent(
                                                  locationType:
                                                      LetDemLocationType.home,
                                                  showDivider: false,
                                                  onPlaceSelected:
                                                      (MapBoxPlace p) {
                                                    context
                                                        .read<
                                                            SearchLocationBloc>()
                                                        .add(
                                                          CreateLocationEvent(
                                                            locationType:
                                                                LetDemLocationType
                                                                    .home,
                                                            name: p.name,
                                                            latitude: 1,
                                                            longitude: 1,
                                                          ),
                                                        );
                                                  },
                                                  onMapBoxPlaceDeleted:
                                                      (MapBoxPlace place) {},
                                                  onLetDemLocationDeleted:
                                                      (LetDemLocation
                                                          location) {},
                                                ),
                                                Dimens.space(2),
                                              ],
                                            )
                                          : Column(
                                              children: state.locations
                                                  .where((e) =>
                                                      e.type ==
                                                      LetDemLocationType.home)
                                                  .map(
                                                (e) {
                                                  return SavedAddressComponent(
                                                    onMapBoxPlaceDeleted:
                                                        (MapBoxPlace place) {},
                                                    onLetDemLocationDeleted:
                                                        (LetDemLocation
                                                            location) {
                                                      context
                                                          .read<
                                                              SearchLocationBloc>()
                                                          .add(const DeleteLocationEvent(
                                                              locationType:
                                                                  LetDemLocationType
                                                                      .home));
                                                    },
                                                    locationType:
                                                        LetDemLocationType.home,
                                                    showDivider: true,
                                                    apiPlace: e,
                                                    onPlaceSelected:
                                                        (MapBoxPlace p) {},
                                                  );
                                                },
                                              ).toList(),
                                            )),
                                  SizedBox(
                                      child: state.locations
                                              .where(
                                                (e) =>
                                                    e.type ==
                                                    LetDemLocationType.work,
                                              )
                                              .isEmpty
                                          ? Column(
                                              children: [
                                                SavedAddressComponent(
                                                  locationType:
                                                      LetDemLocationType.work,
                                                  showDivider: false,
                                                  onPlaceSelected:
                                                      (MapBoxPlace p) {
                                                    context
                                                        .read<
                                                            SearchLocationBloc>()
                                                        .add(
                                                          CreateLocationEvent(
                                                            locationType:
                                                                LetDemLocationType
                                                                    .work,
                                                            name: p.name,
                                                            latitude: 1,
                                                            longitude: 1,
                                                          ),
                                                        );
                                                  },
                                                  onMapBoxPlaceDeleted:
                                                      (MapBoxPlace place) {},
                                                  onLetDemLocationDeleted:
                                                      (LetDemLocation
                                                          location) {},
                                                ),
                                                Dimens.space(2),
                                              ],
                                            )
                                          : Column(
                                              children: state.locations
                                                  .where(
                                                (e) =>
                                                    e.type ==
                                                    LetDemLocationType.work,
                                              )
                                                  .map(
                                                (e) {
                                                  return SavedAddressComponent(
                                                    locationType:
                                                        LetDemLocationType.work,
                                                    showDivider: true,
                                                    apiPlace: e,
                                                    onPlaceSelected:
                                                        (MapBoxPlace p) {},
                                                    onMapBoxPlaceDeleted:
                                                        (MapBoxPlace place) {},
                                                    onLetDemLocationDeleted:
                                                        (LetDemLocation
                                                            location) {
                                                      context
                                                          .read<
                                                              SearchLocationBloc>()
                                                          .add(const DeleteLocationEvent(
                                                              locationType:
                                                                  LetDemLocationType
                                                                      .work));
                                                    },
                                                  );
                                                },
                                              ).toList(),
                                            )),
                                  Dimens.space(2),
                                  Row(
                                    children: state.recentPlaces.isEmpty
                                        ? []
                                        : [
                                            Text(
                                              'Recent',
                                              style: Typo.mediumBody.copyWith(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              child: state.recentPlaces.isEmpty
                                                  ? const SizedBox()
                                                  : GestureDetector(
                                                      onTap: () {
                                                        context
                                                            .read<
                                                                SearchLocationBloc>()
                                                            .add(
                                                                const ClearRecentLocationEvent());
                                                      },
                                                      child: Text(
                                                        'Clear all',
                                                        style: Typo.mediumBody
                                                            .copyWith(
                                                          color: AppColors
                                                              .primary400,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                  ),
                                  Dimens.space(2),
                                  Column(
                                    children: state.recentPlaces.isEmpty
                                        ? []
                                        : state.recentPlaces.map((e) {
                                            return SavedAddressComponent(
                                              place: e,
                                              locationType:
                                                  LetDemLocationType.other,
                                              onPlaceSelected:
                                                  (MapBoxPlace p) async {
                                                MapboxService.getLatLng(
                                                        p.fullAddress)
                                                    .then((value) {
                                                  print(value!.latitude);
                                                  print(value.longitude);
                                                  NavigatorHelper.to(
                                                    TrafficRouteLineExample(
                                                      lat: value.latitude,
                                                      lng: value.longitude,
                                                    ),
                                                  );
                                                });
                                              },
                                              onMapBoxPlaceDeleted:
                                                  (MapBoxPlace place) {
                                                context
                                                    .read<SearchLocationBloc>()
                                                    .add(
                                                        DeleteRecentLocationEvent(
                                                            place: place));
                                              },
                                              onLetDemLocationDeleted:
                                                  (LetDemLocation location) {},
                                            );
                                          }).toList(),
                                  ),
                                ],
                        ),
                      )
                    : const SizedBox();
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
        // circle avatar shimmer
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
