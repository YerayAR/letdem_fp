import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/popups/success_dialog.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';

import '../../../../../../enums/EventTypes.dart';

class AddEventBottomSheet extends StatefulWidget {
  const AddEventBottomSheet({super.key});

  @override
  State<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<AddEventBottomSheet> {
  EventTypes selectedType = EventTypes.police;
  late final Future<CurrentLocationPayload?> _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = MapboxService.getPlaceFromLatLng(); // Runs only once
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentLocationPayload?>(
        future: _locationFuture,
        builder: (context, snapshot) {
          return BlocConsumer<ActivitiesBloc, ActivitiesState>(
            listener: (context, state) {
              if (state is ActivitiesError) {
                Toast.showError(state.error);
              }
              if (state is ActivitiesPublished) {
                context.read<MapBloc>().add(GetNearbyPlaces(
                      queryParams: MapQueryParams(
                        currentPoint:
                            "${snapshot.data!.latitude},${snapshot.data!.longitude}",
                        radius: 8000,
                        drivingMode: false,
                        options: ['spaces', 'events'],
                      ),
                    ));
                context.read<UserBloc>().add(FetchUserInfoEvent());

                Navigator.of(context).pop();
                AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: "Event Published\nSuccessfully",
                    subtext:
                        "Your event have been published successfully, people can now see this event on map.",
                    onProceed: () {
                      NavigatorHelper.pop();
                    },
                  ),
                );
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(Dimens.defaultMargin / 2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Event type",
                          style: Typo.largeBody
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Iconsax.close_circle5,
                            color: AppColors.neutral100,
                          ),
                        ),
                      ],
                    ),
                    Dimens.space(4),
                    Row(
                      spacing: 15,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: EventTypes.values
                          .map(
                            (e) => Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedType = e;
                                  });
                                },
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    height: 93,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: selectedType == e
                                          ? Border.all(
                                              color: AppColors.primary200,
                                              width: 2)
                                          : Border.all(
                                              color: AppColors.neutral50,
                                              width: 2),
                                    ),
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          getEventTypeIcon(e),
                                          width: 50,
                                          height: 50,
                                        ),
                                        Dimens.space(2),
                                        Text(
                                          eventTypeToString(e),
                                          style: Typo.smallBody.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Dimens.space(4),
                    PrimaryButton(
                      isDisabled:
                          snapshot.connectionState == ConnectionState.waiting ||
                              snapshot.data == null,
                      isLoading: state is ActivitiesLoading,
                      onTap: () {
                        BlocProvider.of<ActivitiesBloc>(context).add(
                          PublishRoadEventEvent(
                            type: getEnumName(selectedType),
                            latitude: snapshot.data!.latitude,
                            longitude: snapshot.data!.longitude,
                            locationName: snapshot.data!.locationName!,
                          ),
                        );
                      },
                      text: 'Publish',
                    ),
                    Dimens.space(6),
                  ],
                ),
              );
            },
          );
        });
  }
}
