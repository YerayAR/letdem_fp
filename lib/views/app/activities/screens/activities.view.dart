import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/car/car_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart'; // Ensure these imports are correct
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/models/auth/map/nearby_payload.model.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/activities/screens/view_all.view.dart';
import 'package:letdem/views/app/activities/widgets/contribution_item.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_car_registered.widget.dart';
import 'package:letdem/views/app/activities/widgets/no_contribution.widget.dart';
import 'package:letdem/views/app/activities/widgets/registered_car.widget.dart';
import 'package:letdem/views/app/notifications/views/notification.view.dart';
import 'package:letdem/views/app/profile/widgets/profile_section.widget.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

import '../../home/home.view.dart';

class ConfirmedSpaceReviewView extends StatefulWidget {
  final ReservedSpacePayload payload;

  const ConfirmedSpaceReviewView({super.key, required this.payload});

  @override
  State<ConfirmedSpaceReviewView> createState() =>
      _ConfirmedSpaceReviewViewState();
}

class _ConfirmedSpaceReviewViewState extends State<ConfirmedSpaceReviewView> {
  String otp = "";
  OtpFieldController otpbox = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StyledBody(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledAppBar(
          title: "Space Details",
          onTap: () {
            NavigatorHelper.pop();
          },
          icon: Iconsax.close_circle5,
        ),
        Dimens.space(2),
        Expanded(
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/1/19/Blue_Disc_Parking_Area_Markings_Blue_Paint.JPG",
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // Confirmation Code Card

              // Properties Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
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
                      ),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            getSpaceTypeIcon(widget.payload.type),
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            getSpaceAvailabilityMessage(widget.payload.type),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
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
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.green600,
                                child: const Icon(
                                  IconlyBold.wallet,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '€${widget.payload.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Dimens.space(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 25,
                children: [
                  Icon(
                    Iconsax.car,
                    color: AppColors.neutral500,
                    size: 25,
                  ),
                  Container(
                    width: 55,
                    height: 2,
                    decoration: BoxDecoration(color: AppColors.neutral100),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: widget.payload.status == "RESERVED"
                              ? AppColors.green500
                              : AppColors.red500,
                          child: const Icon(
                            Icons.done,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Dimens.space(1),
                      Text(
                        widget.payload.status,
                        style: Typo.mediumBody.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 55,
                    height: 2,
                    decoration: BoxDecoration(color: AppColors.neutral100),
                  ),
                  Icon(
                    Iconsax.location,
                    color: AppColors.neutral500,
                    size: 25,
                  ),
                ],
              ),
              Dimens.space(6),

              PrimaryButton(
                text: "Confirm Order",
                onTap: () {
                  AppPopup.showBottomSheet(
                    context,
                    Padding(
                      padding: EdgeInsets.all(Dimens.defaultMargin),
                      child: Column(
                        children: [
                          Text(
                            "Confirmation Code",
                            textAlign: TextAlign.center,
                            style: Typo.heading4
                                .copyWith(color: AppColors.neutral600),
                          ),
                          Text(
                            "The requester of the space will give you a 6-digit confirmation number, enter it here.",
                            textAlign: TextAlign.center,
                            style: Typo.mediumBody
                                .copyWith(color: AppColors.neutral400),
                          ),
                          Dimens.space(3),
                          OTPTextField(
                            length: 6,
                            width: MediaQuery.of(context).size.width,
                            otpFieldStyle: OtpFieldStyle(
                              enabledBorderColor: AppColors.neutral100,
                              borderColor: Colors.black.withOpacity(0.2),
                            ),
                            fieldWidth: 50,
                            controller: otpbox,
                            style: const TextStyle(fontSize: 17),
                            spaceBetween: 5,
                            textFieldAlignment: MainAxisAlignment.center,
                            fieldStyle: FieldStyle.box,
                            onChanged: (value) {
                              setState(() {
                                otp = value;
                              });
                            },
                            onCompleted: (pin) {
                              setState(() {
                                otp = pin;
                              });
                            },
                          ),
                          Dimens.space(3),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.50,
                            decoration: BoxDecoration(
                              color: AppColors.secondary50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: Dimens.defaultMargin / 2,
                              horizontal: Dimens.defaultMargin,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Kindly ensure that the confirmation code works before you give out the space',
                                  textAlign: TextAlign.center,
                                  style: Typo.mediumBody.copyWith(
                                    color: AppColors.secondary600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Dimens.space(17),
                          PrimaryButton(
                              text: "Confirm Order",
                              onTap: () {
                                if (otp.isEmpty || otp.length < 6) {
                                  Toast.showError(
                                    "Please enter the confirmation code",
                                  );
                                  return;
                                }
                                context
                                    .read<ActivitiesBloc>()
                                    .add(ConfirmSpaceReserveEvent(
                                      confirmationCode: ConfirmationCodeDTO(
                                        code: otp,
                                        spaceID: widget.payload.id,
                                      ),
                                    ));
                              }),
                          Dimens.space(2),
                          PrimaryButton(
                            text: "Cancel",
                            color: AppColors.neutral100,
                            onTap: () {
                              NavigatorHelper.pop();
                            },
                            textColor: Colors.black,
                            background: Colors.white,
                            borderWidth: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                textColor: Colors.white,
              ),
            ],
          ),
        )
        // Add more details as needed
      ],
    ));
  }
}

class ActiveReservationView extends StatelessWidget {
  final ReservedSpacePayload payload;
  const ActiveReservationView({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (payload.isOwner) {
          NavigatorHelper.to(
            ReservedSpaceDetailView(
                details: payload,
                space: Space(
                  id: payload.id,
                  type: payload.type,
                  image:
                      "https://upload.wikimedia.org/wikipedia/commons/1/19/Blue_Disc_Parking_Area_Markings_Blue_Paint.JPG",
                  location: Location(
                    address: '',
                    point: Point(lat: 2, lng: 2),
                    streetName: '',
                  ),
                  created: DateTime.now(),
                  resourceType: 'space',
                )),
          );
        } else {
          NavigatorHelper.to(
            ConfirmedSpaceReviewView(
              payload: payload,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: Dimens.defaultMargin,
          horizontal: Dimens.defaultMargin,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      getSpaceTypeIcon(payload.type),
                      width: 25,
                      height: 25,
                    ),
                    Dimens.space(1),
                    Text(getSpaceAvailabilityMessage(payload.type),
                        style: Typo.mediumBody.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: payload.status == "RESERVED"
                          ? AppColors.green500
                          : AppColors.red500,
                    ),
                    Dimens.space(1),
                    Text('Active',
                        style: Typo.mediumBody.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ],
            ),
            Dimens.space(2),
            Row(
              children: [
                Row(
                  spacing: 20,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock5,
                          color: AppColors.neutral500,
                          size: 17,
                        ),
                        Dimens.space(1),
                        Text(getTimeRemaining(payload.expireAt),
                            style: Typo.mediumBody.copyWith(
                                fontWeight: FontWeight.w500, fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Iconsax.money5,
                          color: AppColors.neutral500,
                          size: 17,
                        ),
                        Dimens.space(1),
                        Text(
                            payload.price == null
                                ? "Free"
                                : "${payload.price}€",
                            style: Typo.mediumBody.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            )),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  "View details",
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum ContributionType {
  space,
  event,
}

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF5F5F5),
      child: BlocConsumer<ActivitiesBloc, ActivitiesState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return StyledBody(
            isBottomPadding: false,
            children: [
              StyledAppBar(
                suffix: context.userProfile!.notificationsCount == 0
                    ? null
                    : CircleAvatar(
                        radius: 8,
                        backgroundColor: AppColors.red500,
                        child: Text(
                          context.userProfile!.notificationsCount.toString(),
                          style: Typo.smallBody.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                title: 'Activities',
                onTap: () {
                  NavigatorHelper.to(const NotificationsView());
                },
                icon: Iconsax.notification5,
              ),

              BlocConsumer<CarBloc, CarState>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  if (state is CarLoaded) {
                    return ProfileSection(
                      child: [
                        state.car != null
                            ? Column(
                                children: [
                                  RegisteredCarWidget(
                                    car: state.car!,
                                  ),
                                  Dimens.space(1),
                                  LastParkedWidget(
                                    lastParked: state.car!.lastParkingLocation,
                                  ),
                                ],
                              )
                            : const NoCarRegisteredWidget(),
                      ],
                    );
                  }
                  return const ProfileSection(
                    child: [
                      NoCarRegisteredWidget(),
                    ],
                  );
                },
              ),
              SizedBox(
                  child: context.userProfile!.activeReservation == null
                      ? null
                      : ActiveReservationView(
                          payload: context.userProfile!.activeReservation!)),
              // AccountSection(
              //   child: [
              Expanded(
                child: ProfileSection(
                  onCallToAction: () {
                    NavigatorHelper.to(const ViewAllView());
                  },
                  padding: context.userProfile != null &&
                          context.userProfile!.contributions.isNotEmpty
                      ? const EdgeInsets.only(top: 20)
                      : const EdgeInsets.symmetric(vertical: 20),
                  title: "Contributions",
                  callToAction: "See all",
                  child: [
                    Expanded(
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            top: 25,
                            bottom: context.userProfile != null &&
                                    context.userProfile!.contributions.isEmpty
                                ? 0
                                : 25,
                            left: 25,
                            right: 25,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: !(context.userProfile != null &&
                                    context.userProfile!.contributions.isEmpty)
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  )
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                          ),
                          child: Center(
                            child: context.userProfile != null &&
                                    context.userProfile!.contributions.isEmpty
                                ? const NoContributionsWidget()
                                : ListView(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      for (var activity in context
                                              .userProfile?.contributions ??
                                          [])
                                        ContributionItem(
                                          showDivider: context
                                                  .userProfile!.contributions
                                                  .indexOf(activity) !=
                                              context.userProfile!.contributions
                                                      .length -
                                                  1,
                                          type: activity.type.toLowerCase() ==
                                                  "space"
                                              ? ContributionType.space
                                              : ContributionType.event,
                                          activity: activity,
                                        ),
                                    ],
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
            ],

            // ),
            // ],
          );
        },
      ),
    );
  }
}
