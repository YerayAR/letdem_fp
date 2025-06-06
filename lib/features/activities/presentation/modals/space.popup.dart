import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/views/spaces/reserved_space.view.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/add_payment_method.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/payment_methods.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

import '../../../../common/widgets/chip.dart';
import '../../../auth/models/nearby_payload.model.dart';

class SpacePopupSheet extends StatelessWidget {
  final Space space;
  final GeoCoordinates currentPosition;

  const SpacePopupSheet({
    required this.space,
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
          _buildHeader(context),
          Dimens.space(3),
          _buildPaymentCard(context),
          _buildReserveButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image(
            image: NetworkImage(space.image),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
        Dimens.space(2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeRow(),
              Dimens.space(1),
              _buildStreetAndDistance(),
              Dimens.space(1),
              _buildExpirationBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeRow() {
    return Row(
      children: [
        SvgPicture.asset(getSpaceTypeIcon(space.type), width: 20, height: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            getSpaceAvailabilityMessage(space.type),
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Dimens.space(2),
        if (space.isPremium)
          Text(
            "€${space.price}",
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w800),
          ),
      ],
    );
  }

  Widget _buildStreetAndDistance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          space.location.streetName,
          style: Typo.largeBody.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        DecoratedChip(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          text: '${_distanceToSpace()} ${context.l10n.away}',
          textStyle: Typo.smallBody.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.green600,
          ),
          icon: Iconsax.clock5,
          color: AppColors.green500,
        ),
      ],
    );
  }

  Widget _buildExpirationBadge() {
    if (!space.isPremium || space.expirationDate == null) {
      return const SizedBox.shrink();
    }

    return DecoratedChip(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      text: getTimeLeftMessage(DateTime.now(), space.expirationDate!),
      textStyle: Typo.smallBody.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary500,
      ),
      icon: Iconsax.clock5,
      color: AppColors.primary200,
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    if (!space.isPremium) return const SizedBox();

    final method = context.userProfile!.defaultPaymentMethod;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral50),
      ),
      child: method != null
          ? Row(
              children: [
                Image.asset(getCardIcon(method.brand), width: 40, height: 40),
                Dimens.space(1),
                Text(
                  context.l10n.cardEndingWith(method.brand, method.last4),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => NavigatorHelper.to(const PaymentMethodsScreen()),
                  child: Icon(Icons.keyboard_arrow_right_sharp,
                      size: 25, color: AppColors.neutral100),
                ),
              ],
            )
          : GestureDetector(
              onTap: () => NavigatorHelper.to(const AddPaymentMethod()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.addPaymentMethod,
                    style: Typo.mediumBody.copyWith(
                      color: AppColors.primary500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(IconlyBold.arrow_right_2,
                      size: 18, color: AppColors.neutral100),
                ],
              ),
            ),
    );
  }

  Widget _buildReserveButton(BuildContext context) {
    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is SpaceReserved) {
          AppPopup.showDialogSheet(
            context,
            SuccessDialog(
              onProceed: () {
                NavigatorHelper.to(ReservedSpaceDetailView(
                  space: space,
                  details: state.spaceID,
                ));
              },
              title: context.l10n.paymentSuccessful,
              subtext: context.l10n.spaceReservedSuccess,
              buttonText: context.l10n.getSpaceDetails,
            ),
          );
        } else if (state is ActivitiesError) {
          Toast.showError(state.error);
        }
      },
      builder: (context, state) {
        return PrimaryButton(
          icon: space.isPremium ? null : Iconsax.location5,
          isLoading: state is ActivitiesLoading,
          text: space.isPremium 
              ? context.l10n.reserveSpace 
              : context.l10n.navigateToSpace,
          onTap: () {
            if (space.isPremium) {
              if (context.userProfile!.defaultPaymentMethod == null) {
                NavigatorHelper.to(const AddPaymentMethod());
              } else {
                context.read<ActivitiesBloc>().add(
                      ReserveSpaceEvent(
                        spaceID: space.id,
                        paymentMethodID: context
                            .userProfile!.defaultPaymentMethod!.paymentMethodId,
                      ),
                    );
              }
            } else {
              NavigatorHelper.to(
                NavigationMapScreen(
                  hideToggle: true,
                  spaceDetails: space,
                  destinationStreetName: space.location.streetName,
                  latitude: space.location.point.lat,
                  longitude: space.location.point.lng,
                ),
              );
            }
          },
        );
      },
    );
  }

  String _distanceToSpace() {
    return parseMeters(geolocator.Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      space.location.point.lat,
      space.location.point.lng,
    ));
  }
}
