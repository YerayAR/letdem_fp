import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/map/presentation/views/publish_space/publish_space.view.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../common/widgets/appbar.dart';
import '../../../../../common/widgets/body.dart';
import '../../../../../common/widgets/button.dart';
import '../../../../../infrastructure/services/res/navigator.dart';
import '../../../../../infrastructure/toast/toast/toast.dart';
import '../../../../auth/models/nearby_payload.model.dart';

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
            child: ListView(
              children: [
                _buildImage(),
                const SizedBox(height: 24),
                _buildConfirmationCard(),
                const SizedBox(height: 24),
                _buildPropertiesRow(),
                const SizedBox(height: 24),
                _buildNavigateButton(context),
                const SizedBox(height: 16),
                _buildCallButton(),
              ],
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
      title: 'Reserved Space',
      onTap: () => NavigatorHelper.pop(),
      icon: Iconsax.close_circle5,
    );
  }

  // ---------------------------------------------------------------------------
  // Top Image
  // ---------------------------------------------------------------------------
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        space.image,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmation Card
  // ---------------------------------------------------------------------------
  Widget _buildConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Confirmation Code',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            details.confirmationCode,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildShareNote(),
          Dimens.space(3),
          _buildOwnerPlate(),
        ],
      ),
    );
  }

  Widget _buildShareNote() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Share this code with the parking space owner',
        style: TextStyle(color: AppColors.secondary600, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOwnerPlate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'The Owner\'s Plate Number: ',
          style: TextStyle(fontSize: 16, color: Colors.black54),
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
  Widget _buildPropertiesRow() {
    return Row(
      children: [
        Expanded(child: _buildSpaceInfoCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildPriceInfoCard()),
      ],
    );
  }

  Widget _buildSpaceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SvgPicture.asset(getSpaceTypeIcon(space.type), width: 60, height: 60),
          const SizedBox(height: 12),
          Text(
            getSpaceAvailabilityMessage(space.type),
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
            '€${details.price.toStringAsFixed(2)}',
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
        NavigatorHelper.to(NavigationMapScreen(
          hideToggle: true,
          spaceDetails: space,
          destinationStreetName: space.location.streetName,
          latitude: space.location.point.lat,
          longitude: space.location.point.lng,
        ));
      },
      text: 'Navigate to Space',
    );
  }

  Widget _buildCallButton() {
    return PrimaryButton(
      onTap: () async {
        Uri url = Uri.parse('tel:${details.phone}');
        if (!await launchUrl(url)) {
          Toast.showError("Could not launch dialer");
        } else {
          print("Dialer launched successfully");
        }
      },
      borderWidth: 1,
      background: Colors.white,
      textColor: AppColors.neutral500,
      icon: IconlyBold.call,
      text: 'Call Space Owner',
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
