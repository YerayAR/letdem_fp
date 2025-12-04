import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/chip.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/features/payment_methods/presentation/empty_states/empty_payment_method.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/add_payment_method.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';
import 'package:letdem/models/payment/payment.model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final Function(PaymentMethodModel)? onPaymentMethodSelected;
  const PaymentMethodsScreen({super.key, this.onPaymentMethodSelected});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool showOptions = false;
  bool showDeleteConfirmation = false;

  @override
  void initState() {
    context.read<PaymentMethodBloc>().add(const FetchPaymentMethods());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
        listener: (context, state) {
          if (state is PaymentMethodError) {
            Toast.showError(state.message);
          }
          if (state is PaymentMethodLoaded) {
            context.read<UserBloc>().add(FetchUserInfoEvent());
          }
        },
        builder: (context, state) {
          return StyledBody(
            children: [
              StyledAppBar(
                title: context.l10n.paymentMethods,
                onTap: () {
                  NavigatorHelper.pop();
                },
                icon: Icons.close,
              ),
              Dimens.space(3),
              Expanded(
                child: state is PaymentMethodLoaded
                    ? (state).paymentMethods.isEmpty
                        ? const EmptyPaymentMethodView()
                        : ListView.builder(
                            itemCount: state.paymentMethods.length,
                            itemBuilder: (context, index) {
                              final paymentMethod = state.paymentMethods[index];
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (widget.onPaymentMethodSelected != null) {
                                    widget.onPaymentMethodSelected!(
                                      paymentMethod,
                                    );
                                  }
                                },
                                child: _buildCardItem(
                                  cardId: paymentMethod.paymentMethodId,
                                  last4: paymentMethod.last4,
                                  brand: getBrandName(paymentMethod.brand),
                                  expireDate:
                                      '${paymentMethod.getMonthName(context)} - ${paymentMethod.expYear}',
                                  cardType: paymentMethod.brand,
                                  holderName: paymentMethod.holderName,
                                  isDefault: paymentMethod.isDefault,
                                  onMenuTap: () {
                                    setState(() {
                                      showOptions = true;
                                    });
                                  },
                                ),
                              );
                            },
                          )
                    : const Center(
                        child: CupertinoActivityIndicator(),
                      ),
              ),
              // Visa Card Item (Default)

              Dimens.space(3),

              // Add New Card Button
              PrimaryButton(
                text: context.l10n.addNewCard,
                onTap: () {
                  NavigatorHelper.to(const AddPaymentMethod());
                  // Add new card action
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardItem({
    required String cardType,
    required String holderName,
    required String cardId,
    required bool isDefault,
    required String brand,
    required String expireDate,
    required String last4,
    required VoidCallback onMenuTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.cardEndingWith(brand, last4),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  // Icono de opciones
                  GestureDetector(
                    onTap: () {
                      AppPopup.showBottomSheet(
                          context,
                          _buildPaymentMethodOptionsSheet(
                            context,
                            cardId,
                            // Show options sheet
                          ));
                    },
                    child: Icon(
                      Icons.more_horiz,
                      color: AppColors.neutral300,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Dimens.space(1),
          Text(
            context.l10n.expireDate(expireDate),
            style: Typo.smallBody.copyWith(
                fontWeight: FontWeight.w500, color: AppColors.neutral400),
          ),
          Dimens.space(2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                holderName,
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Image.asset(
                getCardIcon(cardType),
                width: 40,
                height: 40,
              ),
            ],
          ),
          if (isDefault) ...[
            Dimens.space(1),
            Text(
              context.l10n.defaultCardTagline,
              style: Typo.smallBody.copyWith(
                color: AppColors.neutral500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOptionsSheet(
    BuildContext context,
    String cardId,
  ) {
    return Padding(
      padding: EdgeInsets.all(Dimens.defaultMargin / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                context.l10n.paymentMethod,
                style: Typo.largeBody
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Iconsax.close_circle5,
                  color: AppColors.neutral100,
                ),
              ),
            ],
          ),
          Dimens.space(3),
          GestureDetector(
            onTap: () {
              context.read<PaymentMethodBloc>().add(
                    SetDefaultPaymentMethod(cardId),
                  );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.primary50,
                  child: Icon(
                    Iconsax.star,
                    color: AppColors.primary500,
                    size: 17,
                  ),
                ),
                Dimens.space(2),
                Text(context.l10n.makeDefault,
                    style: Typo.largeBody.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral600,
                    )),
              ],
            ),
          ),
          Dimens.space(1),
          Divider(
            color: AppColors.neutral50,
          ),
          Dimens.space(1),
          BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
            listener: (context, state) {
              if (state is PaymentMethodError) {
                Toast.showError(state.message);
              }
              if (state is PaymentMethodLoaded && !(state.isDeleting)) {
                Navigator.of(context).pop();
              }
              // TODO: implement listener
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  context.read<PaymentMethodBloc>().add(
                        RemovePaymentMethod(cardId),
                      );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.red50,
                      child: Icon(
                        Iconsax.trash,
                        color: AppColors.red500,
                        size: 17,
                      ),
                    ),
                    Dimens.space(2),
                    Text(context.l10n.delete,
                        style: Typo.largeBody.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral600,
                        )),
                    if (context.read<PaymentMethodBloc>().state
                            is PaymentMethodLoaded &&
                        (context.read<PaymentMethodBloc>().state
                                as PaymentMethodLoaded)
                            .isDeleting)
                      Row(
                        children: [
                          Dimens.space(1),
                          const CupertinoActivityIndicator(
                            radius: 8,
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
          Dimens.space(3),
        ],
      ),
    );
  }

  Widget _buildDeleteConfirmationDialog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 32,
              color: Colors.amber.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.confirmDeleteCard,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.deleteCardConfirmation('0967'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showDeleteConfirmation = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              context.l10n.noKeepCard,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                showDeleteConfirmation = false;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              context.l10n.yesDeleteCard,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

getCardIcon(String cardType) {
  switch (cardType.toLowerCase()) {
    case 'visa':
      return AppAssets.visa;
    case 'mastercard':
      return AppAssets.masterCard;
    case 'americanexpress':
      return AppAssets.americanExpress;
    case 'discover':
      return AppAssets.discover;
    default:
      return '';
  }
}

getBrandName(String cardType) {
  print('Card Type: $cardType');
  switch (cardType.toLowerCase()) {
    case 'visa':
      return 'Visa';
    case 'mastercard':
      return 'MasterCard';
    case 'americanexpress' || 'amex' || 'american express':
      return 'Amex';
    case 'discover':
      return 'Discover';
    default:
      return '';
  }
}
