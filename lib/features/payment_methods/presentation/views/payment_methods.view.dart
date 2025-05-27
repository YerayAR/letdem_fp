import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/features/payment_methods/presentation/empty_states/empty_payment_method.view.dart';
import 'package:letdem/features/payment_methods/presentation/views/add_payment_method.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

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
          // TODO: implement listener
        },
        builder: (context, state) {
          return StyledBody(
            children: [
              StyledAppBar(
                title: 'Payment Methods',
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
                              return _buildCardItem(
                                cardId: paymentMethod.paymentMethodId,
                                last4: paymentMethod.last4,
                                cardType: paymentMethod.brand,
                                holderName: paymentMethod.holderName,
                                isDefault: paymentMethod.isDefault,
                                onMenuTap: () {
                                  setState(() {
                                    showOptions = true;
                                  });
                                },
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
                text: 'Add New Card',
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
                'Visa ending with $last4',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  SizedBox(
                    child: !isDefault
                        ? null
                        : DecoratedChip(
                            text: 'Default',
                            backgroundColor: AppColors.secondary50,
                            color: AppColors.secondary600,
                          ),
                  ),
                  Dimens.space(1),
                  GestureDetector(
                    onTap: () {
                      AppPopup.showBottomSheet(
                          context,
                          _buildPayoutOptionsSheet(
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
          Text(
            'Expire Date: March, 2026',
            style: Typo.smallBody.copyWith(
                fontWeight: FontWeight.w500, color: AppColors.neutral400),
          ),
          Dimens.space(3),
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
        ],
      ),
    );
  }

  Widget _buildPayoutOptionsSheet(
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
                "Payment method",
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
                Text("Make Default",
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
          GestureDetector(
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
                Text("Delete",
                    style: Typo.largeBody.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral600,
                    )),
              ],
            ),
          ),
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
          const Text(
            'Confirm Delete Card',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Are you sure you want to delete Card ending with 0967? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(
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
            child: const Text(
              'No, Keep Card',
              style: TextStyle(
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
            child: const Text(
              'Yes, Delete Card',
              style: TextStyle(
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
    default:
      return '';
  }
}
