import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/constants/credentials.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/repositories/activity.repository.dart';
import 'package:letdem/features/auth/auth_bloc.dart';
import 'package:letdem/features/auth/repositories/auth.repository.dart';
import 'package:letdem/features/search/repository/search_location.repository.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/services/mapbox_search/models/model.dart';
import 'package:letdem/services/mapbox_search/models/service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/home/home.view.dart';
import 'package:letdem/views/welcome/views/splash.view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(AppCredentials.mapBoxAccessToken);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepository(),
        ),
        RepositoryProvider<ActivityRepository>(
          create: (_) => ActivityRepository(),
        ),
        RepositoryProvider(
          create: (_) => SearchLocationRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SearchLocationBloc(
              searchLocationRepository:
                  context.read<SearchLocationRepository>(),
            ),
          ),
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider<ActivitiesBloc>(
            create: (context) => ActivitiesBloc(
              activityRepository: context.read<ActivityRepository>(),
            ),
          ),
        ],
        child: const LetDemApp(),
      ),
    ),
  );
}

class LetDemApp extends StatelessWidget {
  const LetDemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FlashyFlushbarProvider.init(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: AppColors.neutral600,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'DMSans',
      ),
      navigatorKey: NavigatorHelper.navigatorKey,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: const SplashView(),
    );
  }
}

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
                return state is SearchLocationLoaded
                    ? Expanded(
                        child: ListView(
                          children: _searchResults.isNotEmpty &&
                                  _controller.text.isNotEmpty
                              ? _searchResults
                                  .map((e) => SavedAddressComponent(
                                        place: e,
                                        onPlaceSelected: (MapBoxPlace p) {},
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
                                                  );
                                                },
                                              ).toList(),
                                            )),
                                  Dimens.space(2),
                                  Row(
                                    children: [
                                      Text(
                                        'Favourites',
                                        style: Typo.mediumBody.copyWith(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Clear all',
                                        style: Typo.mediumBody.copyWith(
                                          color: AppColors.primary400,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Dimens.space(2),
                                  SavedAddressComponent(
                                    place: samplePlace,
                                    locationType: LetDemLocationType.other,
                                    onPlaceSelected: (MapBoxPlace p) {},
                                  ),
                                  SavedAddressComponent(
                                    place: samplePlace,
                                    locationType: LetDemLocationType.other,
                                    onPlaceSelected: (MapBoxPlace p) {},
                                    showDivider: false,
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

class AddLocationBottomSheet extends StatefulWidget {
  final Function(MapBoxPlace) onLocationSelected;
  const AddLocationBottomSheet({super.key, required this.onLocationSelected});

  @override
  State<AddLocationBottomSheet> createState() => _AddLocationBottomSheetState();
}

class _AddLocationBottomSheetState extends State<AddLocationBottomSheet> {
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
              children: [
                IconButton(
                  icon: Icon(
                    CupertinoIcons.back,
                    color: AppColors.neutral400,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  "Home Address",
                  style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                ),
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

            // List of search results or saved addresses
            BlocBuilder<SearchLocationBloc, SearchLocationState>(
              builder: (context, state) {
                return Expanded(
                  child: ListView(
                    children:
                        _searchResults.isNotEmpty && _controller.text.isNotEmpty
                            ? _searchResults
                                .map((e) => SavedAddressComponent(
                                      place: e,
                                      onPlaceSelected: (MapBoxPlace p) {
                                        widget.onLocationSelected(p);
                                        NavigatorHelper.pop();
                                      },
                                    ))
                                .toList()
                            : [],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
