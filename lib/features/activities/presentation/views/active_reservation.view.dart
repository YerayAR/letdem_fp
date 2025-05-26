import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/views/confirmed_space_detail.view.dart';
import 'package:letdem/features/auth/models/nearby_payload.model.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/views/app/home/views/reserved_space.view.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

class ActiveReservationView extends StatelessWidget {
  final ReservedSpacePayload payload;

  const ActiveReservationView({
    super.key,
    required this.payload,
  });

  void _navigateToDetails(BuildContext context) {
    if (!payload.isOwner) {
      NavigatorHelper.to(
        ReservedSpaceDetailView(
          details: payload,
          space: _buildSpaceFromPayload(),
        ),
      );
    } else {
      NavigatorHelper.to(
        ConfirmedSpaceReviewView(payload: payload),
      );
    }
  }

  Space _buildSpaceFromPayload() {
    final space = payload.space;
    return Space(
      id: payload.id,
      type: space.type,
      image: space.image,
      location: Location(
        address: '',
        point: Point(lat: 2, lng: 2),
        streetName: '',
      ),
      created: DateTime.now(),
      resourceType: 'space',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
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
            _buildHeader(),
            Dimens.space(2),
            _buildDetailsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTypeInfo(),
        _buildStatusInfo(),
      ],
    );
  }

  Widget _buildTypeInfo() {
    return Row(
      children: [
        SvgPicture.asset(
          getSpaceTypeIcon(payload.space.type),
          width: 25,
          height: 25,
        ),
        Dimens.space(1),
        Text(
          getSpaceAvailabilityMessage(payload.space.type),
          style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    final isReserved = payload.status == "RESERVED";
    return Row(
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor: isReserved ? AppColors.green500 : AppColors.red500,
        ),
        Dimens.space(1),
        Text(
          payload.status,
          style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildDetailsRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildIconText(
                  Iconsax.clock5, getTimeRemaining(payload.expireAt)),
              Dimens.space(3),
              _buildIconText(
                Iconsax.money5,
                payload.price == null ? "Free" : "${payload.price}€",
              ),
            ],
          ),
        ),
        Text(
          "View details",
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.primary400,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neutral500, size: 17),
        Dimens.space(1),
        Text(
          text,
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
