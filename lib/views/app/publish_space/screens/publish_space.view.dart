import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';

class PublishSpaceScreen extends StatelessWidget {
  const PublishSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Dimens.defaultMargin),
          child: PrimaryButton(
            onTap: () {},
            text: 'Continue',
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Publish Space'),
      ),
      body: StyledBody(
        children: [
          const TakePictureWidget(),
          Dimens.space(2),
          const PublishingLocationWidget(),
        ],
      ),
    );
  }
}

class PublishingLocationWidget extends StatelessWidget {
  const PublishingLocationWidget({super.key});

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Location",
                    style: Typo.smallBody.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 14,
                    )),
                Text(
                  "Street39, Avenida de Niceto Alcalá",
                  style: Typo.largeBody.copyWith(
                    fontWeight: FontWeight.w500,
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

class TakePictureWidget extends StatelessWidget {
  const TakePictureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
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
    );
  }
}
