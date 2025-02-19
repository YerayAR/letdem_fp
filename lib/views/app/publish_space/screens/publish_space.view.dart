import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/location/location.service.dart';

enum PublishSpaceType {
  free,
  blueZone,
  disabled,
  greenZone,
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
      return 'Green Zone';
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
  }
}

class PublishSpaceScreen extends StatefulWidget {
  final File file;
  const PublishSpaceScreen({super.key, required this.file});

  @override
  State<PublishSpaceScreen> createState() => _PublishSpaceScreenState();
}

class _PublishSpaceScreenState extends State<PublishSpaceScreen> {
  File? selectedSpacePicture;
  PublishSpaceType selectedType = PublishSpaceType.free;

  @override
  void initState() {
    selectedSpacePicture = widget.file;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: MapboxService.getPlaceFromLatLng(),
        builder: (context, snapshot) {
          return Scaffold(
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Dimens.defaultMargin),
                  child: PrimaryButton(
                    onTap: () {},
                    isDisabled:
                        snapshot.data == null || selectedSpacePicture == null,
                    text: 'Continue',
                  ),
                ),
              ),
              appBar: AppBar(
                title: const Text('Publish Space'),
              ),
              body: StyledBody(
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
                    position: snapshot.data,
                  ),
                  Dimens.space(2),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: PublishSpaceType.values
                        .map((e) => Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedType = e;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  height: 90,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                            ))
                        .toList(),
                  ),
                ],
              ));
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconlyBold.camera, size: 30, color: AppColors.neutral400),
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
