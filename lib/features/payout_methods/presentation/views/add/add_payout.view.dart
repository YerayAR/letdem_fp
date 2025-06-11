import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class AddPayoutMethodView extends StatefulWidget {
  const AddPayoutMethodView({super.key});

  @override
  State<AddPayoutMethodView> createState() => _AddPayoutMethodViewState();
}

class _AddPayoutMethodViewState extends State<AddPayoutMethodView> {
  late TextEditingController _accountNumberController;

  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    _accountNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PayoutMethodBloc, PayoutMethodState>(
        listener: (context, state) {
          if (state is PayoutMethodFailure) {
            Toast.showError(state.message);
          }
          if (state is PayoutMethodSuccess) {
            AppPopup.showDialogSheet(
                context,
                SuccessDialog(
                  title: context.l10n.payoutMethodAdded,
                  subtext: context.l10n.payoutMethodAddedDescription,
                  onProceed: () {
                    NavigatorHelper.pop();
                    NavigatorHelper.pop();
                  },
                ));
          }
          // TODO: implement listener
        },
        builder: (context, state) {
          return StyledBody(
            isBottomPadding: false,
            children: [
              StyledAppBar(
                title: context.l10n.addPayoutMethod,
                onTap: () => Navigator.of(context).pop(),
                icon: Icons.close,
              ),
              Dimens.space(2),
              TextInputField(
                controller: _accountNumberController,
                label: context.l10n.accountNumber,
                placeHolder: context.l10n.accountNumberExample,
              ),
              Row(
                children: [
                  Text(context.l10n.makeDefaultPaymentMethod,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral600,
                      )),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = !isDefault;
                        });
                        // Handle switch change
                      },
                      activeColor: AppColors.primary500,
                    ),
                  ),
                ],
              ),
              Dimens.space(5),
              PrimaryButton(
                text: context.l10n.addPayoutMethod,
                background: AppColors.primary500,
                textColor: Colors.white,
                isLoading: state is PayoutMethodLoading,
                onTap: () {
                  if (_accountNumberController.text.trim().isEmpty) {
                    Toast.showError(context.l10n.pleaseEnterAccountNumber);
                    return;
                  }
                  print(
                      "Account Number: ${_accountNumberController.text.trim()}");
                  context.read<PayoutMethodBloc>().add(
                        AddPayoutMethod(
                          PayoutMethodDTO(
                            accountNumber: _accountNumberController.text.trim(),
                            isDefault: isDefault,
                          ),
                        ),
                      );
                  // Handle add payout method logic
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
