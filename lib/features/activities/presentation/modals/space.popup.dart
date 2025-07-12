import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:here_sdk/core.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/activities/activities_bloc.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/activities/presentation/views/spaces/reserved_space.view.dart';
import 'package:letdem/features/map/presentation/views/route.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/add_payment_method.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/payment_methods.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/payment/payment.model.dart';

import '../../../../common/widgets/chip.dart';
import '../../../auth/models/nearby_payload.model.dart';

class SpacePopupSheet extends StatefulWidget {
  final Space space;
  final GeoCoordinates currentPosition;

  final VoidCallback onRefreshTrigger;

  const SpacePopupSheet({
    required this.space,
    required this.onRefreshTrigger,
    required this.currentPosition,
    super.key,
  });

  @override
  State<SpacePopupSheet> createState() => _SpacePopupSheetState();
}

class _SpacePopupSheetState extends State<SpacePopupSheet> {
  PaymentMethodModel? _selectedPaymentMethod;

  @override
  void initState() {
    _selectedPaymentMethod = context.userProfile!.defaultPaymentMethod;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.defaultMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.spaceDetailsTitle,
                style: Typo.largeBody.copyWith(fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Iconsax.close_circle5,
                      size: 25, color: AppColors.neutral300)),
            ],
          ),
          Dimens.space(4),
          _buildHeader(context),
          Dimens.space(3),
          _buildPaymentCard(context, _selectedPaymentMethod),
          SizedBox(
              child: (widget.space.isOwner)
                  ? BlocConsumer<ActivitiesBloc, ActivitiesState>(
                      listener: (context, state) {
                        if (state is ActivitiesPublished) {
                          widget.onRefreshTrigger();
                          context.read<UserBloc>().add(FetchUserInfoEvent());
                          AppPopup.showDialogSheet(
                            context,
                            SuccessDialog(
                              title: context.l10n.spaceDeleted,
                              subtext: context.l10n.spaceDeletedSubtext,
                              onProceed: () {
                                NavigatorHelper.popAll();
                              },
                            ),
                          );
                        } else if (state is ActivitiesError) {
                          Toast.showError(state.error);
                        }
                        // TODO: implement listener
                      },
                      builder: (context, state) {
                        return PrimaryButton(
                          text: context.l10n.delete,
                          color: AppColors.red500,
                          onTap: () {
                            AppPopup.showDialogSheet(
                              context,
                              ConfirmationDialog(
                                title: context.l10n.deleteSpaceTitle,
                                subtext: context.l10n.deleteSpaceSubtext,
                                onProceed: () {
                                  context.read<ActivitiesBloc>().add(
                                        DeleteSpaceEvent(
                                            spaceID: widget.space.id),
                                      );
                                  NavigatorHelper.pop();
                                },
                              ),
                            );
                          },
                        );
                      },
                    )
                  : _buildReserveButton(context, widget.space)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image(
            image: NetworkImage(widget.space.image),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
        Dimens.space(2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeRow(context),
              Dimens.space(1),
              _buildStreetAndDistance(context),
              Dimens.space(1),
              _buildExpirationBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeRow(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(getSpaceTypeIcon(widget.space.type),
            width: 20, height: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            getSpaceAvailabilityMessage(widget.space.type, context),
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Dimens.space(2),
        if (widget.space.isPremium)
          Text(
            "${widget.space.price} €",
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w800),
          ),
      ],
    );
  }

  Widget _buildStreetAndDistance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.space.location.streetName,
          style: Typo.largeBody.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        DecoratedChip(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          text: '${_distanceToSpace(context)} ${context.l10n.away}',
          textStyle: Typo.smallBody.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.green600,
          ),
          icon: Iconsax.clock5,
          color: AppColors.green500,
        ),
      ],
    );
  }

  Widget _buildExpirationBadge() {
    if (!widget.space.isPremium || widget.space.expirationDate == null) {
      return const SizedBox.shrink();
    }

    return DecoratedChip(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      text: getTimeLeftMessage(DateTime.now(), widget.space.expirationDate!),
      textStyle: Typo.smallBody.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.primary500,
      ),
      icon: Iconsax.clock5,
      color: AppColors.primary200,
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentMethodModel? method) {
    if (!widget.space.isPremium || widget.space.isOwner)
      return const SizedBox();

    return GestureDetector(
      onTap: () {
        if (context.userProfile!.defaultPaymentMethod == null) {
          NavigatorHelper.to(AddPaymentMethod(
              onPaymentMethodAdded: (e) => setState(() {
                    _selectedPaymentMethod = e;
                  })));
        } else {
          NavigatorHelper.to(
              PaymentMethodsScreen(onPaymentMethodSelected: (event) {
            NavigatorHelper.pop();
            setState(() {
              _selectedPaymentMethod = event;
            });
          }));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral50),
        ),
        child: method != null
            ? Row(
                children: [
                  Image.asset(getCardIcon(_selectedPaymentMethod!.brand),
                      width: 40, height: 40),
                  Dimens.space(1),
                  Text(
                    context.l10n.cardEndingWith(
                        getBrandName(method.brand), method.last4),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        NavigatorHelper.to(const PaymentMethodsScreen()),
                    child: Icon(Icons.keyboard_arrow_right_sharp,
                        size: 25, color: AppColors.neutral100),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.addPaymentMethod,
                    style: Typo.mediumBody.copyWith(
                      color: AppColors.primary500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(IconlyBold.arrow_right_2,
                      size: 18, color: AppColors.neutral100),
                ],
              ),
      ),
    );
  }

  Future<void> handle3DSPayment(
      String clientSecret, VoidCallback onSuccess, VoidCallback onError) async {
    try {
      // Triggers the 3DS flow if required
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );

      if (paymentIntent.status == PaymentIntentsStatus.RequiresCapture ||
          paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        // Payment succeeded
        onSuccess();
      } else {
        // Payment failed or requires further action
        onError();
      }
    } on StripeException catch (e) {
      onError();
      print('Stripe error: ${e.error.localizedMessage}');
    } catch (e) {
      onError();
      Toast.show('Unhandled error: $e');
    }
  }

  Widget _buildReserveButton(BuildContext context, Space space) {
    return BlocConsumer<ActivitiesBloc, ActivitiesState>(
      listener: (context, state) {
        if (state is ReserveSpaceError) {
          if (state.status == ReserveSpaceErrorStatus.requiredAction) {
            handle3DSPayment(
              state.clientSecret!,
              () {
                context.read<UserBloc>().add(FetchUserInfoEvent());
                NavigatorHelper.pop();
                AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: context.l10n.spaceReserved,
                    subtext: context.l10n.paymentSuccessfulReservation,
                    onProceed: () {
                      NavigatorHelper.pop();
                      widget.onRefreshTrigger();
                    },
                  ),
                );
                widget.onRefreshTrigger();
              },
              () {
                AppPopup.showDialogSheet(
                  context,
                  ConfirmationDialog(
                    isError: true,
                    onSecondaryCTA: () {
                      NavigatorHelper.pop();
                      NavigatorHelper.to(PaymentMethodsScreen(
                        onPaymentMethodSelected: (e) => setState(() {
                          NavigatorHelper.pop();

                          setState(() {
                            _selectedPaymentMethod = e;
                          });
                        }),
                      ));
                    },
                    title: "Payment Failed",
                    secondaryCTAText: "Change payment method",
                    subtext:
                        "The reservation failed because your payment didn’t go through successfully",
                    onProceed: () {
                      NavigatorHelper.pop();
                    },
                  ),
                );
              },
            );
          } else {
            // Handle generic error
            AppPopup.showDialogSheet(
              context,
              ConfirmationDialog(
                isError: true,
                onSecondaryCTA: () {
                  NavigatorHelper.pop();
                  context.read<ActivitiesBloc>().add(
                        ReserveSpaceEvent(
                            spaceID: widget.space.id,
                            paymentMethodID:
                                _selectedPaymentMethod!.paymentMethodId),
                      );
                },
                title: context.l10n.errorReserveSpace,
                subtext:
                    "${state.error}. Please try again later. If the issue persists, contact support.",
                onProceed: () {
                  NavigatorHelper.pop();
                },
              ),
            );
          }
        }
        if (state is SpaceReserved) {
          widget.onRefreshTrigger();
          context.read<UserBloc>().add(FetchUserInfoEvent());
          NavigatorHelper.pop();
          NavigatorHelper.to(ReservedSpaceDetailView(
            space: widget.space,
            details: state.spaceID,
          ));
        } else if (state is ActivitiesError) {
          Toast.showError(state.error);
        }
      },
      builder: (context, state) {
        return PrimaryButton(
          icon: widget.space.isPremium ? null : Iconsax.location5,
          isLoading: state is ActivitiesLoading,
          text: space.isPremium
              ? context.l10n.reserveSpace
              : context.l10n.navigateToSpace,
          onTap: () {
            if (widget.space.isPremium) {
              if (context.userProfile!.defaultPaymentMethod == null) {
                NavigatorHelper.to(const AddPaymentMethod());
              } else {
                context.read<ActivitiesBloc>().add(
                      ReserveSpaceEvent(
                        spaceID: widget.space.id,
                        paymentMethodID:
                            _selectedPaymentMethod!.paymentMethodId,
                      ),
                    );
              }
            } else {
              NavigatorHelper.to(
                NavigationMapScreen(
                  hideToggle: true,
                  spaceDetails: widget.space,
                  destinationStreetName: widget.space.location.streetName,
                  latitude: widget.space.location.point.lat,
                  longitude: widget.space.location.point.lng,
                ),
              );
            }
          },
        );
      },
    );
  }

  String _distanceToSpace(BuildContext context) {
    return parseMeters(geolocator.Geolocator.distanceBetween(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
      widget.space.location.point.lat,
      widget.space.location.point.lng,
    ));
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String subtext;
  final bool isError;
  final VoidCallback onProceed;
  final String? secondaryCTAText;
  final VoidCallback? onSecondaryCTA;

  const ConfirmationDialog({
    super.key,
    this.title = '',
    this.secondaryCTAText,
    this.onSecondaryCTA,
    this.subtext = '',
    this.isError = false,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.red50,
                child: Icon(
                  Icons.error,
                  size: 45,
                  color: AppColors.red500,
                ),
              ),
            ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Typo.heading4.copyWith(fontWeight: FontWeight.w800),
          ),
          Dimens.space(2),
          Text(
            subtext,
            style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
          Dimens.space(4),
          PrimaryButton(
            text: context.l10n.proceed,
            onTap: onProceed,
            color: AppColors.primary500,
            textColor: Colors.white,
          ),
          if (secondaryCTAText != null && onSecondaryCTA != null) ...[
            Dimens.space(2),
            GestureDetector(
              onTap: onSecondaryCTA,
              child: Text(
                secondaryCTAText!,
                style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
