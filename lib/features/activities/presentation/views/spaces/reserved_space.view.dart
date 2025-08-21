import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/modals/space.popup.dart';
import 'package:letdem/features/map/presentation/views/navigate.view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../common/widgets/appbar.dart';
import '../../../../../common/widgets/body.dart';
import '../../../../../common/widgets/button.dart';
import '../../../../../infrastructure/services/res/navigator.dart';
import '../../../../../infrastructure/toast/toast/toast.dart';
import '../../../../auth/models/nearby_payload.model.dart';
import '../../../activities_bloc.dart';

class ReservedSpaceDetailView extends StatelessWidget {
  final ReservedSpacePayload details;
  final Space space;

  const ReservedSpaceDetailView({
    super.key,
    required this.details,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        isBottomPadding: false,
        children: [
          _buildAppBar(context),
          Expanded(
            child: BlocConsumer<ActivitiesBloc, ActivitiesState>(
              listener: (context, state) {
                if (state is ActivitiesError) {
                  Toast.showError(state.error);
                } else if (state is ActivitiesLoaded) {
                  // Handle success state, e.g., show a success message or navigate
                  NavigatorHelper.pop();
                }
                // TODO: implement listener
              },
              builder: (context, state) {
                return ListView(
                  children: [
                    _buildImage(context),
                    const SizedBox(height: 24),
                    _buildConfirmationCard(context),
                    const SizedBox(height: 24),
                    _buildPropertiesRow(context),
                    const SizedBox(height: 24),
                    _buildNavigateButton(context),
                    const SizedBox(height: 16),
                    _buildCallButton(context),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      isLoading:
                          context.watch<ActivitiesBloc>().state
                              is ActivitiesLoading,
                      text: context.l10n.cancel,
                      color: AppColors.red500,
                      textColor: Colors.white,
                      onTap: () {
                        AppPopup.showDialogSheet(
                          context,
                          ConfirmationDialog(
                            onProceed: () {
                              NavigatorHelper.pop();

                              context.read<ActivitiesBloc>().add(
                                CancelReservationEvent(spaceID: details.id),
                              );
                            },
                            title:
                                context.l10n.cancelReservationConfirmationTitle,
                            subtext:
                                context.l10n.cancelReservationConfirmationText,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App Bar
  // ---------------------------------------------------------------------------
  Widget _buildAppBar(BuildContext context) {
    return StyledAppBar(
      title: context.l10n.reservedSpace,
      onTap: () => NavigatorHelper.pop(),
      icon: Iconsax.close_circle5,
    );
  }

  // ---------------------------------------------------------------------------
  // Top Image
  // ---------------------------------------------------------------------------
  Widget _buildImage(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            space.image,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmation Card
  // ---------------------------------------------------------------------------
  Widget _buildConfirmationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Center(
            child: Text(
              context.l10n.confirmationCodeTitle,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            details.confirmationCode,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildShareNote(context),
          const SizedBox(height: 16),
          DecoratedChip(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            text: details.space.location.streetName,
            icon: IconlyBold.location,
            color: AppColors.primary500,
          ),
          Dimens.space(3),
          _buildOwnerPlate(context),
        ],
      ),
    );
  }

  Widget _buildShareNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.shareCodeOwner,
        style: TextStyle(color: AppColors.secondary600, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOwnerPlate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.ownerPlateNumber,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Text(
          details.carPlateNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Space Info Row
  // ---------------------------------------------------------------------------
  Widget _buildPropertiesRow(context) {
    return Row(
      children: [
        Expanded(child: _buildSpaceInfoCard(context)),
        const SizedBox(width: 16),
        Expanded(child: _buildPriceInfoCard()),
      ],
    );
  }

  Widget _buildSpaceInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SvgPicture.asset(getSpaceTypeIcon(space.type), width: 60, height: 60),
          const SizedBox(height: 12),
          Text(
            getSpaceAvailabilityMessage(space.type, context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.green600,
            child: const Icon(IconlyBold.wallet, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '${details.price.toStringAsFixed(2)} €',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Buttons
  // ---------------------------------------------------------------------------
  Widget _buildNavigateButton(BuildContext context) {
    return PrimaryButton(
      onTap: () {
        NavigatorHelper.to(
          NavigationView(
            destinationLat: details.space.location.point.lat,
            destinationLng: details.space.location.point.lng,
          ),
        );
      },
      text: context.l10n.navigateToSpace,
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return PrimaryButton(
      onTap: () async {
        Uri url = Uri.parse('tel:${details.phone}');
        if (!await launchUrl(url)) {
          Toast.showError(context.l10n.couldNotLaunchDialer);
        } else {
          print("Dialer launched successfully");
        }
      },
      borderWidth: 1,
      background: Colors.white,
      textColor: AppColors.neutral500,
      icon: IconlyBold.call,
      text: context.l10n.callSpaceOwner,
    );
  }

  // ---------------------------------------------------------------------------
  // Styles
  // ---------------------------------------------------------------------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
}
