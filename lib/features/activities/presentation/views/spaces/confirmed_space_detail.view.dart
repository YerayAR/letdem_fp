import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class ConfirmedSpaceReviewView extends StatefulWidget {
  final ReservedSpacePayload payload;

  const ConfirmedSpaceReviewView({super.key, required this.payload});

  @override
  State<ConfirmedSpaceReviewView> createState() =>
      _ConfirmedSpaceReviewViewState();
}

class _ConfirmedSpaceReviewViewState extends State<ConfirmedSpaceReviewView> {
  String otp = "";
  final OtpFieldController otpController = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          if (state is ActivitiesPublished) {
            context.read<UserBloc>().add(FetchUserInfoEvent());
            // Handle successful space reservation confirmation
            AppPopup.showDialogSheet(
              context,
              const SuccessDialog(
                title: "Action Successful",
                subtext:
                    "Your space was ordered successfully, we will update your account shortly.",
                onProceed: NavigatorHelper.popAll,
              ),
            );
          }

          // TODO: implement listener
        },
        builder: (context, state) {
          return StyledBody(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              Dimens.space(2),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 24),
                    _buildInfoCards(),
                    Dimens.space(6),
                    _buildStatusStepper(),
                    Dimens.space(6),
                    _buildConfirmOrderButton(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return StyledAppBar(
      title: context.l10n.spaceDetails,
      onTap: NavigatorHelper.pop,
      icon: Iconsax.close_circle5,
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        widget.payload.space.image,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(child: _buildTypeCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildPriceCard()),
      ],
    );
  }

  Widget _buildTypeCard() {
    return _infoCard(
      child: Column(
        children: [
          SvgPicture.asset(
            getSpaceTypeIcon(widget.payload.space.type),
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 12),
          Text(
            getSpaceAvailabilityMessage(widget.payload.space.type, context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return _infoCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.green600,
            child: const Icon(IconlyBold.wallet, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.payload.price.toStringAsFixed(2)} €',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusStepper() {
    final bool isReserved = widget.payload.status == "RESERVED";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.car, color: AppColors.neutral500, size: 25),
        _stepperDivider(),
        _statusStep(isReserved),
        _stepperDivider(),
        Icon(Iconsax.location, color: AppColors.neutral500, size: 25),
      ],
    );
  }

  Widget _stepperDivider() {
    return Container(
      width: 55,
      height: 2,
      color: AppColors.neutral100,
    );
  }

  Widget _statusStep(bool isReserved) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              isReserved ? AppColors.green500 : AppColors.neutral200,
          child: Icon(
            isReserved ? Icons.done : Iconsax.clock5,
            size: 17,
            color: Colors.white,
          ),
        ),
        Dimens.space(1),
        Text(
          isReserved ? context.l10n.reserved : context.l10n.waiting,
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmOrderButton(BuildContext context) {
    return PrimaryButton(
      text: context.l10n.confirmOrder,
      onTap: () => _showConfirmationSheet(context),
      textColor: Colors.white,
    );
  }

  void _showConfirmationSheet(BuildContext context) {
    AppPopup.showBottomSheet(
      context,
      BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          if (state is SpaceReserved) {
            NavigatorHelper.pop();
            AppPopup.showBottomSheet(
              context,
              SuccessDialog(
                title: context.l10n.spaceReserved,
                subtext: context.l10n.spaceReservedSuccessfully,
                onProceed: NavigatorHelper.popAll,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(Dimens.defaultMargin),
            child: Column(
              children: [
                _buildSheetTitle(),
                _buildOtpField(),
                Dimens.space(3),
                _buildOtpNote(),
                Dimens.space(17),
                _buildConfirmAndCancelButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSheetTitle() {
    return Column(
      children: [
        Text(context.l10n.confirmationCode,
            style: Typo.heading4.copyWith(color: AppColors.neutral600)),
        Text(
          context.l10n.enterConfirmationCode,
          textAlign: TextAlign.center,
          style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
        ),
        Dimens.space(4),
      ],
    );
  }

  Widget _buildOtpField() {
    return OTPTextField(
      length: 6,
      controller: otpController,
      width: double.infinity,
      fieldWidth: 50,
      textFieldAlignment: MainAxisAlignment.center,
      fieldStyle: FieldStyle.box,
      spaceBetween: 5,
      style: const TextStyle(fontSize: 17),
      otpFieldStyle: OtpFieldStyle(
        borderColor: Colors.black.withOpacity(0.2),
        enabledBorderColor: AppColors.neutral100,
      ),
      onChanged: (value) => setState(() => otp = value),
      onCompleted: (value) => setState(() => otp = value),
    );
  }

  Widget _buildOtpNote() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.66,
      padding: EdgeInsets.symmetric(
        vertical: Dimens.defaultMargin / 2,
        horizontal: Dimens.defaultMargin,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        context.l10n.confirmationCodeWarning,
        textAlign: TextAlign.center,
        style: Typo.mediumBody.copyWith(
          color: AppColors.secondary600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildConfirmAndCancelButtons(BuildContext context) {
    final isLoading =
        context.watch<ActivitiesBloc>().state is ActivitiesLoading;

    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Column(
          children: [
            PrimaryButton(
              isLoading: isLoading,
              text: context.l10n.confirmOrder,
              onTap: () {
                if (otp.length < 6) {
                  Toast.showError(context.l10n.pleaseEnterConfirmationCode);
                  return;
                }

                context.read<ActivitiesBloc>().add(
                      ConfirmSpaceReserveEvent(
                        confirmationCode: ConfirmationCodeDTO(
                          code: otp,
                          spaceID: widget.payload.id,
                        ),
                      ),
                    );
              },
            ),
            Dimens.space(2),
            PrimaryButton(
              text: context.l10n.cancel,
              color: AppColors.neutral100,
              textColor: Colors.black,
              background: Colors.white,
              borderWidth: 1,
              onTap: NavigatorHelper.pop,
            ),
          ],
        );
      },
    );
  }
}
