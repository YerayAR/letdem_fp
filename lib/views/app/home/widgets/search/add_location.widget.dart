import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/search/search_location_bloc.dart';
import 'package:letdem/infrastructure/services/mapbox_search/models/service.dart';
import 'package:letdem/models/location/local_location.model.dart';
import 'package:letdem/views/app/home/widgets/search/address_component.widget.dart';

import '../../../../../infrastructure/services/mapbox_search/models/model.dart';
import '../../../../../infrastructure/services/res/navigator.dart';

class AddLocationBottomSheet extends StatefulWidget {
  final String title;
  final Function(MapBoxPlace) onLocationSelected;
  const AddLocationBottomSheet(
      {super.key, required this.onLocationSelected, required this.title});

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
        var results =
            await MapboxSearchApiService().getLocationResults(query, context);
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
                  widget.title,
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
              showDeleteIcon: true,
              prefixIcon: IconlyLight.search,
              placeHolder: 'Enter destination',
            ),
            Dimens.space(2),

            // List of search results or saved addresses
            BlocBuilder<SearchLocationBloc, SearchLocationState>(
              builder: (context, state) {
                return Expanded(
                  child: ListView(
                    children: _searchResults.isNotEmpty &&
                            _controller.text.isNotEmpty
                        ? _searchResults
                            .map((e) => SavedAddressComponent(
                                  place: e,
                                  onPlaceSelected: (MapBoxPlace p) {
                                    widget.onLocationSelected(p);
                                    NavigatorHelper.pop();
                                  },
                                  onMapBoxPlaceDeleted: (MapBoxPlace place) {},
                                  onLetDemLocationDeleted:
                                      (LetDemLocation location) {},
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
