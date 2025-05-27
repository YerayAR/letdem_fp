import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/multi_selector.popup.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/EventTypes.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/infrastructure/services/map/map_asset_provider.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class EventFeedback extends StatelessWidget {
  final Event event;
  final double currentDistance;
  final VoidCallback? onSubmit;

  const EventFeedback(
      {super.key,
      required this.event,
      this.onSubmit,
      required this.currentDistance});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(Dimens.defaultMargin + 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image(
                  image: AssetImage(
                    MapAssetsProvider.getAssetEvent(event.type),
                  ),
                  height: 40,
                ),
                Dimens.space(1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getEventMessage(event.type),
                          style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        Dimens.space(2),
                        DecoratedChip(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          text: '${currentDistance.floor()}m away',
                          textStyle: Typo.smallBody.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.green600,
                          ),
                          icon: Iconsax.clock,
                          color: AppColors.green500,
                        )
                      ],
                    ),
                    Text(
                      event.location.streetName,
                      style: Typo.largeBody.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral600),
                    ),
                  ],
                ),
              ],
            ),
            Dimens.space(4),
            Row(
              children: <Widget>[
                Flexible(
                  child: PrimaryButton(
                    onTap: () {
                      NavigatorHelper.pop();
                    },
                    text: 'Got it, Thank you',
                  ),
                ),
                Dimens.space(1),
                Flexible(
                  child: PrimaryButton(
                    outline: true,
                    onTap: () {
                      AppPopup.showBottomSheet(
                        context,
                        FeedbackForm(eventID: event.id),
                      );
                    },
                    background: AppColors.primary50,
                    borderColor: Colors.transparent,
                    color: AppColors.primary500,
                    text: 'Feedback',
                  ),
                )
              ],
            ),
          ],
        ));
  }
}

class FeedbackForm extends StatelessWidget {
  final String eventID;
  const FeedbackForm({super.key, required this.eventID});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is ActivitiesPublished) {
          // Show success message
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              title: "Your feedback has been submitted",
              subtext: "Thank you for your input!",
              onProceed: () {
                NavigatorHelper.pop();
                NavigatorHelper.pop();
              },
            ),
          );
        }
        if (state is ActivitiesError) {
          // Show error message
          Toast.showError(
            state.error,
          );
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        return MultiSelectPopup(
          title: "Event Feedback",
          isLoading: state is ActivitiesLoading,
          items: [
            MultiSelectItem(
              backgroundColor: AppColors.green50,
              icon: Icons.done,
              iconColor: AppColors.green500,
              text: "It’s still there",
              onTap: () {
                context.read<ActivitiesBloc>().add(
                      EventFeedBackEvent(
                        eventID: eventID,
                        isThere: true,
                      ),
                    );
              },
            ),
            Divider(color: AppColors.neutral50, height: 1),
            MultiSelectItem(
              backgroundColor: AppColors.secondary50,
              icon: Icons.close,
              iconColor: AppColors.secondary600,
              text: "It’s not there",
              onTap: () {
                context.read<ActivitiesBloc>().add(
                      EventFeedBackEvent(
                        eventID: eventID,
                        isThere: false,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}
