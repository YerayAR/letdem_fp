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
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
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
      body: StyledBody(
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
      ),
    );
  }

  Widget _buildAppBar() {
    return const StyledAppBar(
      title: "Space Details",
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
            getSpaceAvailabilityMessage(widget.payload.space.type),
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
            '€${widget.payload.price.toStringAsFixed(2)}',
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
          isReserved ? "Reserved" : "Waiting",
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
      text: "Confirm Order",
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
              const SuccessDialog(
                title: "Space Reserved",
                subtext: "Your space has been reserved successfully.",
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
        Text("Confirmation Code",
            style: Typo.heading4.copyWith(color: AppColors.neutral600)),
        Text(
          "The requester of the space will give you a 6-digit confirmation number, enter it here.",
          textAlign: TextAlign.center,
          style: Typo.mediumBody.copyWith(color: AppColors.neutral400),
        ),
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
        'Kindly ensure that the confirmation code works before you give out the space',
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

    return Column(
      children: [
        PrimaryButton(
          isLoading: isLoading,
          text: "Confirm Order",
          onTap: () {
            if (otp.length < 6) {
              Toast.showError("Please enter the confirmation code");
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
          text: "Cancel",
          color: AppColors.neutral100,
          textColor: Colors.black,
          background: Colors.white,
          borderWidth: 1,
          onTap: NavigatorHelper.pop,
        ),
      ],
    );
  }
}
