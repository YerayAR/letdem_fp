import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/textfield.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/earning_account_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_event.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/earning_account/presentation/views/connect_account.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

class BankInfoView extends StatefulWidget {
  final VoidCallback onNext;
  const BankInfoView({super.key, required this.onNext});

  @override
  State<BankInfoView> createState() => _BankInfoViewState();
}

class _BankInfoViewState extends State<BankInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final dto =
          EarningsBankAccountDTO(accountNumber: _ibanController.text.trim());
      context.read<EarningsBloc>().add(SubmitEarningsBankAccount(dto));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EarningsBloc, EarningsState>(
      listener: (context, state) {
        if (state is EarningsCompleted) {
          context.read<UserBloc>().add(UpdateEarningAccountEvent(
                account: state.info,
              ));

          AppPopup.showDialogSheet(
              NavigatorHelper.navigatorKey.currentState!.context,
              SuccessDialog(
                onProceed: () {
                  NavigatorHelper.pop();
                  NavigatorHelper.pop();
                },
                title: 'Details Submitted',
                buttonText: 'Goi it, Thanks',
                subtext:
                    'Your account connection details submitted successfully, you will soon be able to receive money  for paid spaces. ',
              ));
        } else if (state is EarningsFailure) {
          Toast.showError(state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bank Information',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Enter your IBAN to complete this step',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral600)),
              const SizedBox(height: 30),
              TextInputField(
                label: 'Enter your IBAN',
                placeHolder: 'Eg. ES0700120345030000067890',
                controller: _ibanController,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: AppColors.secondary600),
                    Dimens.space(1),
                    Flexible(
                      child: Text(
                        "Kindly note that this bank account is required to receive payout from our payment provider.",
                        style: TextStyle(
                            fontSize: 14, color: AppColors.secondary600),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  return buildNextButton(context, () {
                    _submit();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
