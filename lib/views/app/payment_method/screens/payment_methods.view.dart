import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/features/payment_methods/payment_method_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/global/widgets/chip.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/payment_method/screens/add_payment_method.view.dart';

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
    context.read<PaymentMethodBloc>().add(FetchPaymentMethods());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
        listener: (context, state) {
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
              // Visa Card Item (Default)
              _buildCardItem(
                cardType: 'visa',
                isDefault: true,
                onMenuTap: () {
                  setState(() {
                    showOptions = true;
                  });
                },
              ),

              // Mastercard Item
              _buildCardItem(
                cardType: 'mastercard',
                isDefault: false,
                onMenuTap: () {
                  setState(() {
                    showOptions = true;
                  });
                },
              ),

              Dimens.space(3),

              // Add New Card Button
              PrimaryButton(
                text: 'Add New Card',
                onTap: () {
                  NavigatorHelper.to(AddPaymentMethod());
                  // Add new card action
                },
              ),
            ],
          );
        },
      ),
    );
  }

  getCardIcon(String cardType) {
    switch (cardType) {
      case 'visa':
        return AppAssets.visa;
      case 'mastercard':
        return AppAssets.masterCard;
      default:
        return '';
    }
  }

  Widget _buildCardItem({
    required String cardType,
    required bool isDefault,
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
              const Text(
                'Visa ending with 0967',
                style: TextStyle(
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
                          context, _buildPayoutOptionsSheet());
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
                'Abubakar Sadeeq Ismail',
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

  Widget _buildPayoutOptionsSheet() {
    return Padding(
      padding: EdgeInsets.all(Dimens.defaultMargin / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                "Payout options",
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
            onTap: () {},
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
            onTap: () {},
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
