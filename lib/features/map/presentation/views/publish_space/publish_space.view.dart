import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/auth/models/map_options.model.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/location/location.service.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/country_codes.model.dart';

class PublishSpaceScreen extends StatefulWidget {
  final File file;
  final bool isPaid;

  const PublishSpaceScreen(
      {super.key, required this.file, required this.isPaid});

  @override
  State<PublishSpaceScreen> createState() => _PublishSpaceScreenState();
}

class _PublishSpaceScreenState extends State<PublishSpaceScreen> {
  File? selectedSpacePicture;
  PublishSpaceType selectedType = PublishSpaceType.free;

  // Page controller for the page view
  late PageController _pageController;

  // Form values for the paid space screen
  String waitingTime = '';
  String price = '';
  String phoneNumber = '';
  String countryCode = '+34'; // Default for Spain as seen in the image

  // Current location data
  CurrentLocationPayload? locationData;

  @override
  void initState() {
    selectedSpacePicture = widget.file;
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _moveToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _publishSpace() {
    // If it's a paid space and we're on the first page, go to the second page
    if (widget.isPaid && _pageController.page == 0) {
      _moveToNextPage();
      return;
    }

    if (widget.isPaid &&
        (waitingTime.isEmpty || price.isEmpty || phoneNumber.isEmpty)) {
      Toast.showError(context.l10n.pleaseEnterAllFields);
      return;
    }

    // Otherwise proceed with publishing
    if (locationData != null) {
      context.read<ActivitiesBloc>().add(
            PublishSpaceEvent(
              type: getEnumText(selectedType),
              image: selectedSpacePicture!,
              locationName: locationData!.locationName!,
              latitude: locationData!.latitude,
              longitude: locationData!.longitude,
              // Include additional fields for paid spaces
              price: widget.isPaid ? price : null,
              waitTime: int.tryParse(waitingTime ?? ''),
              phoneNumber: widget.isPaid ? "$countryCode$phoneNumber" : null,
            ),
          );
    }
  }

  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentLocationPayload?>(
        future: MapboxService.getPlaceFromLatLng(),
        builder: (context, snapshot) {
          // Save location data for use when publishing
          if (snapshot.hasData) {
            locationData = snapshot.data;
          }

          return BlocConsumer<ActivitiesBloc, ActivitiesState>(
            listener: (context, state) {
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

                AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: context.l10n.spacePublishedSuccesfully,
                    subtext: context.l10n.spacePublishedDescription,
                    onProceed: () {
                      NavigatorHelper.pop();
                      NavigatorHelper.pop();
                    },
                  ),
                );
              }
              if (state is ActivitiesError) {
                Toast.showError(state.error);
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    Dimens.space(2),
                    // Row to contain page indicators with proper spacing
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 70,
                          height: 8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.secondary500),
                        ),
                        const SizedBox(width: 8), // consistent spacing
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 70,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _selectedPage == 1
                                ? AppColors.secondary500
                                : AppColors.secondary500.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 16), // add padding at the end
                      ],
                    ),
                  ],
                  title: Text(
                    context.l10n.publishSpace,
                  ),
                ),
                body: PageView(
                  onPageChanged: (int page) {
                    // if user already selected first page and is paid space then don't allow to change page
                    if (widget.isPaid &&
                        _pageController.page == 0 &&
                        page == 1) {
                      return;
                    }
                    setState(() {
                      _selectedPage = page;
                    });
                  },
                  controller: _pageController,
                  physics: widget.isPaid
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  children: [
                    // First page - Space details and type selection
                    StyledBody(
                      children: [
                        TakePictureWidget(
                          file: selectedSpacePicture,
                          onImageSelected: (File file) {
                            setState(() {
                              selectedSpacePicture = file;
                            });
                          },
                        ),
                        Dimens.space(2),
                        PublishingLocationWidget(
                          position: snapshot.data?.locationName ?? "",
                        ),
                        Dimens.space(2),
                        Row(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: PublishSpaceType.values
                              .where((e) =>
                                  e != PublishSpaceType.paidFree &&
                                  e != PublishSpaceType.paidBlue &&
                                  e != PublishSpaceType.paidDisabled &&
                                  e != PublishSpaceType.paidGreenZone)
                              .map((e) => Flexible(
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
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
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
                                                getSpaceTypeIcon(e),
                                                width: 30,
                                                height: 30,
                                              ),
                                              Dimens.space(1),
                                              Text(
                                                getSpaceTypeText(e, context),
                                                style: Typo.smallBody.copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),

                    // Second page - Paid space form
                    widget.isPaid
                        ? StyledBody(
                            children: [
                              TextInputField(
                                label: context.l10n.waitingTimeMinutes,
                                placeHolder: "MM",
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,2}')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    waitingTime = value;
                                  });
                                },
                                inputType: TextFieldType.number,
                                prefixIcon: Iconsax.clock5,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 25,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      AppPopup.showDialogSheet(
                                        context,
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              context.l10n.waitingTime,
                                              style: Typo.heading4,
                                            ),
                                            Dimens.space(2),
                                            Text(
                                              context.l10n.waitingTimeTooltip,
                                              style: Typo.mediumBody,
                                              textAlign: TextAlign.center,
                                            ),
                                            Dimens.space(2),
                                            PrimaryButton(
                                              onTap: () {
                                                NavigatorHelper.pop();
                                              },
                                              text: context.l10n.gotIt,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          context.l10n.whatIsThisWaitingTime,
                                          style: Typo.smallBody.copyWith(
                                            color: AppColors.secondary600,
                                            fontSize: 12,
                                            decorationColor:
                                                AppColors.secondary600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TextInputField(
                                label: context.l10n.price,
                                inputType: TextFieldType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                placeHolder: context.l10n.enterPrice,
                                prefixIcon: Iconsax.money5,
                                onChanged: (value) {
                                  setState(() {
                                    price = value;
                                  });
                                },
                              ),
                              Dimens.space(2),
                              PhoneField(
                                label: context.l10n.phoneNumber,
                                onChanged: (String text, String code) {
                                  setState(() {
                                    phoneNumber = text;
                                    countryCode = code;
                                  });
                                },
                                initialValue: '',
                              )
                            ],
                          )
                        : Container(),
                  ],
                ),
                bottomNavigationBar: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(Dimens.defaultMargin),
                    child: PrimaryButton(
                      isLoading: state is ActivitiesLoading,
                      onTap: _publishSpace,
                      isDisabled:
                          snapshot.data == null || selectedSpacePicture == null,
                      text: (_pageController.hasClients &&
                              _pageController.page == 1)
                          ? context.l10n.publish
                          : (widget.isPaid
                              ? context.l10n.next
                              : context.l10n.publish),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}

class PublishingLocationWidget extends StatelessWidget {
  final String? position;
  const PublishingLocationWidget({super.key, this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(
                Iconsax.location5,
                color: AppColors.primary400,
              ),
            ),
            Dimens.space(2),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(context.l10n.location,
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 14,
                      )),
                  SizedBox(
                    child: position == null
                        ? Text(
                            context.l10n.fetchingLocation,
                            style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Text(
                            position!,
                            style: Typo.largeBody.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TakePictureWidget extends StatefulWidget {
  final Function(File file) onImageSelected;
  final File? file;
  const TakePictureWidget(
      {super.key, required this.onImageSelected, this.file});

  @override
  State<TakePictureWidget> createState() => _TakePictureWidgetState();
}

class _TakePictureWidgetState extends State<TakePictureWidget> {
  void takePhoto() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      widget.onImageSelected(File(file.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        takePhoto();
      },
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          image: widget.file != null
              ? DecorationImage(
                  image: FileImage(widget.file!), fit: BoxFit.cover)
              : null,
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(25),
        ),
        child: widget.file != null
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyBold.camera,
                      size: 30, color: AppColors.neutral400),
                  Dimens.space(1),
                  Text(
                    context.l10n.clickToOpenCamera,
                    style: Typo.largeBody,
                  ),
                ],
              ),
      ),
    );
  }
}

class PaidSpaceForm extends StatelessWidget {
  const PaidSpaceForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: PrimaryButton(
            onTap: () {
              NavigatorHelper.pop();
            },
            text: context.l10n.publish,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(context.l10n.publishPaidSpace),
      ),
      body: StyledBody(
        children: [
          TextInputField(
            label: context.l10n.waitingTime, // Cambiar "Waiting Time"
            placeHolder: context.l10n.waitingTimeMinutes,
            prefixIcon: Iconsax.clock5,
            onChanged: (value) {},
          ),
          TextInputField(
            label: context.l10n.price,
            inputType: TextFieldType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            placeHolder: context.l10n.enterPrice,
            prefixIcon: Iconsax.money5,
            onChanged: (value) {},
          ),
          Dimens.space(2),
          PhoneField(
            label: context.l10n.phoneNumber,
            onChanged: (String text, String countryCode) {},
            initialValue: '',
          )
        ],
      ),
    );
  }
}
