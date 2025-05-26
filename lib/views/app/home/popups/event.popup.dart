import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/enums/EventTypes.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/infrastructure/services/map/map_asset_provider.service.dart';
import 'package:letdem/views/app/maps/navigate.view.dart';

import '../../../../common/popups/popup.dart';
import '../../../../infrastructure/services/res/navigator.dart';

class EventPopupSheet extends StatelessWidget {
  final Event event;
  final GeoCoordinates currentPosition;

  const EventPopupSheet({
    required this.event,
    required this.currentPosition,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.defaultMargin + 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Dimens.space(4),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image(
          image: AssetImage(MapAssetsProvider.getAssetEvent(event.type)),
          height: 40,
        ),
        Dimens.space(1),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  getEventMessage(event.type),
                  style: Typo.largeBody.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Dimens.space(2),
                DecoratedChip(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  text: '${_distanceToEvent()}m away',
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
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: PrimaryButton(
            onTap: () => NavigatorHelper.pop(),
            text: 'Got it, Thank you',
          ),
        ),
        Dimens.space(1),
        Flexible(
          child: PrimaryButton(
            outline: true,
            background: AppColors.primary50,
            borderColor: Colors.transparent,
            color: AppColors.primary500,
            text: 'Feedback',
            onTap: () {
              AppPopup.showBottomSheet(
                context,
                FeedbackForm(eventID: event.id),
              );
            },
          ),
        )
      ],
    );
  }

  int _distanceToEvent() {
    return geolocator.Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      event.location.point.lat,
      event.location.point.lng,
    ).floor();
  }
}
