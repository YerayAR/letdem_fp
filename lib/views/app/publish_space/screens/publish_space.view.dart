import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/map/map_bloc.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/global/models/country_codes.model.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/textfield.dart';
import 'package:letdem/models/auth/map/map_options.model.dart';
import 'package:letdem/services/location/location.service.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';

import '../../../../global/popups/success_dialog.dart';

enum PublishSpaceType {
  free,
  blueZone,
  disabled,
  greenZone,

  paidFree,
  paidBlue,
  paidDisabled,
  paidGreenZone,
}

String getSpaceTypeText(PublishSpaceType type) {
  switch (type) {
    case PublishSpaceType.free:
      return 'Free';
    case PublishSpaceType.blueZone:
      return 'Blue Zone';
    case PublishSpaceType.disabled:
      return 'Disabled';
    case PublishSpaceType.greenZone:
      return 'Green';
    case PublishSpaceType.paidFree:
      return 'Paid Free';
    case PublishSpaceType.paidBlue:
      return 'Paid Blue Zone';
    case PublishSpaceType.paidDisabled:
      return 'Paid Disabled';
    case PublishSpaceType.paidGreenZone:
      return 'Paid Green Zone';
  }
}

String getSpaceAvailabilityMessage(PublishSpaceType spaceType) {
  switch (spaceType) {
    case PublishSpaceType.free:
      return 'Free';
    case PublishSpaceType.blueZone:
      return 'Blue Zone';
    case PublishSpaceType.disabled:
      return 'Disabled';
    case PublishSpaceType.greenZone:
      return 'Green Zone';
    case PublishSpaceType.paidFree:
      return 'Free';
    case PublishSpaceType.paidBlue:
      return 'Blue Zone';
    case PublishSpaceType.paidDisabled:
      return 'Disabled';
    case PublishSpaceType.paidGreenZone:
      return 'Green Zone';
  }
}

PublishSpaceType getEnumFromText(String text, String resourceType) {
  switch (text) {
    case 'FREE':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidFree
          : PublishSpaceType.free;
    case 'BLUE':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidBlue
          : PublishSpaceType.blueZone;
    case 'DISABLED':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidDisabled
          : PublishSpaceType.disabled;
    case 'GREEN':
      return resourceType == 'PaidSpace'
          ? PublishSpaceType.paidGreenZone
          : PublishSpaceType.greenZone;

    default:
      return PublishSpaceType.greenZone;
  }
}

String getEnumText(PublishSpaceType type) {
  switch (type) {
    case PublishSpaceType.free:
      return 'FREE';
    case PublishSpaceType.blueZone:
      return 'BLUE';
    case PublishSpaceType.disabled:
      return 'DISABLED';
    case PublishSpaceType.greenZone:
      return 'GREEN';
    case PublishSpaceType.paidFree:
      return 'FREE';
    case PublishSpaceType.paidBlue:
      return 'BLUE';
    case PublishSpaceType.paidDisabled:
      return 'DISABLED';
    case PublishSpaceType.paidGreenZone:
      return 'GREEN';
  }
}

String getSpaceTypeIcon(PublishSpaceType type) {
  switch (type) {
    case PublishSpaceType.free:
      return AppAssets.free;
    case PublishSpaceType.blueZone:
      return AppAssets.blue;
    case PublishSpaceType.disabled:
      return AppAssets.disabled;
    case PublishSpaceType.greenZone:
      return AppAssets.green;
    case PublishSpaceType.paidFree:
      return AppAssets.free;
    case PublishSpaceType.paidBlue:
      return AppAssets.blue;
    case PublishSpaceType.paidDisabled:
      return AppAssets.disabled;
    case PublishSpaceType.paidGreenZone:
      return AppAssets.green;
  }
}

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
      Toast.showError("Please fill all fields");
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
                    title: "Space Published Successfully",
                    subtext:
                        "Your space have been published successfully, people can now have access to use space.",
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
                            color: _selectedPage == 0
                                ? AppColors.secondary500
                                : AppColors.secondary500.withOpacity(0.3),
                          ),
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
                  title: const Text(
                    'Publish Space',
                  ),
                ),
                body: PageView(
                  onPageChanged: (int page) {
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
                          position: snapshot.data?.locationName,
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
                                                getSpaceTypeText(e),
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
                                label: "Waiting Time (in minutes)",
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
                                            const Text(
                                              "Waiting Time",
                                              style: Typo.heading4,
                                            ),
                                            Dimens.space(2),
                                            const Text(
                                              "This is the maximum amount of time the publisher can wait before they leave, and after this time elapses, the published space will expire.",
                                              style: Typo.mediumBody,
                                              textAlign: TextAlign.center,
                                            ),
                                            Dimens.space(2),
                                            PrimaryButton(
                                              onTap: () {
                                                NavigatorHelper.pop();
                                              },
                                              text: "Got it",
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
                                          "What’s this?",
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
                                label: "Price",
                                inputType: TextFieldType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                placeHolder: "Enter price",
                                prefixIcon: Iconsax.money5,
                                onChanged: (value) {
                                  setState(() {
                                    price = value;
                                  });
                                },
                              ),
                              Dimens.space(2),
                              TSLPhoneField(
                                label: "Phone Number",
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
                          ? "Publish"
                          : (widget.isPaid ? "Next" : "Publish"),
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
                  Text("Location",
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                        fontSize: 14,
                      )),
                  SizedBox(
                    child: position == null
                        ? Text(
                            "Fetching location...",
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
                  const Text(
                    "Click to open camera",
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
            text: "Publish",
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Publish Paid Space'),
      ),
      body: StyledBody(
        children: [
          TextInputField(
            label: "Waiting Time",
            placeHolder: "MM:SS",
            prefixIcon: Iconsax.clock5,
            onChanged: (value) {},
          ),
          TextInputField(
            label: "Price",
            inputType: TextFieldType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            placeHolder: "Enter price",
            prefixIcon: Iconsax.money5,
            onChanged: (value) {},
          ),
          Dimens.space(2),
          TSLPhoneField(
            label: "Phone Number",
            onChanged: (String text, String countryCode) {},
            initialValue: '',
          )
        ],
      ),
    );
  }
}
