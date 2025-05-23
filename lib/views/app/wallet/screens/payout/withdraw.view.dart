import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/features/withdrawals/withdrawal_bloc.dart';
import 'package:letdem/global/popups/popup.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/services/toast/toast.dart';
import 'package:letdem/views/app/wallet/screens/payout/payout.view.dart';
import 'package:letdem/views/auth/views/onboard/verify_account.view.dart';

class AmountInputCard extends StatefulWidget {
  final Function(String)? onChange;

  const AmountInputCard({Key? key, this.onChange}) : super(key: key);

  @override
  _AmountInputCardState createState() => _AmountInputCardState();
}

class _AmountInputCardState extends State<AmountInputCard> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAmount(String value) {
    final balance = context.userProfile!.earningAccount?.balance ?? 0;
    final entered = double.tryParse(value) ?? 0;

    if (entered > balance) {
      setState(() => _errorText = 'Amount cannot exceed €$balance');
      widget.onChange?.call('0');
      return;
    } else {
      setState(() => _errorText = null);
    }

    // Call the onChange callback
    widget.onChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final balance = context.userProfile!.earningAccount?.balance ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimens.defaultMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Amount to receive',
            style: Typo.mediumBody.copyWith(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Dimens.space(1),
          Text(
            '€${(context.userProfile!.earningAccount?.balance ?? 0).toStringAsFixed(2)}',
            style: Typo.heading3.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 36,
            ),
          ),
          // TextField(
          //   controller: _controller,
          //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
          //   textAlign: TextAlign.center,
          //   style: Typo.heading3.copyWith(
          //     fontWeight: FontWeight.w800,
          //     fontSize: 36,
          //   ),
          //   decoration: InputDecoration(
          //     hintText: '€0.00',
          //     hintStyle: Typo.heading3.copyWith(
          //       fontWeight: FontWeight.w800,
          //       fontSize: 36,
          //       color: AppColors.neutral200,
          //     ),
          //     prefixStyle: Typo.heading3.copyWith(
          //       fontWeight: FontWeight.w800,
          //       fontSize: 36,
          //     ),
          //     border: InputBorder.none,
          //     contentPadding: EdgeInsets.zero,
          //   ),
          //   textAlignVertical: TextAlignVertical.center,
          //   inputFormatters: [
          //     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          //   ],
          //   onChanged: _validateAmount,
          // ),
          Dimens.space(1),
          Text(
            _errorText ??
                '€${context.userProfile!.earningAccount?.pendingBalance ?? 0} Pending to be cleared',
            style: Typo.mediumBody.copyWith(
              fontSize: 11,
              color:
                  _errorText != null ? AppColors.red500 : AppColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }
}

class WithdrawView extends StatefulWidget {
  const WithdrawView({super.key});

  @override
  State<WithdrawView> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<WithdrawView> {
  @override
  initState() {
    super.initState();
    BlocProvider.of<PayoutMethodBloc>(context).add(FetchPayoutMethods());
  }

  PayoutMethod? selectedMethod;
  double amount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StyledBody(
      isBottomPadding: true,
      children: [
        StyledAppBar(
          title: 'Withdraw',
          onTap: () => Navigator.of(context).pop(),
          icon: Icons.close,
        ),
        Dimens.space(2),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(Dimens.defaultMargin),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AmountInputCard(
                onChange: (value) {
                  setState(() {
                    amount = double.tryParse(value) ?? 0;
                  });
                  // Handle amount change
                },
              ),
            ],
          ),
        ),
        Dimens.space(2),
        BlocConsumer<PayoutMethodBloc, PayoutMethodState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            if (state is PayoutMethodLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is PayoutMethodFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: Typo.mediumBody.copyWith(color: Colors.red),
                ),
              );
            }
            if (state is PayoutMethodInitial) {
              return const Center(
                child: Text('No payout methods available'),
              );
            }
            if (state is PayoutMethodSuccess) {
              if (state.methods.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Dimens.space(5),
                    EmptyPayoutMethodView(),
                    Dimens.space(5),
                  ],
                );
              }

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: (state).methods.length,
                  // +1 for the add button
                  itemBuilder: (context, index) {
                    final method = (state).methods[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OptionItem(
                        isSelectable: true,
                        method: method,
                        isSelected: selectedMethod == method,
                        onTap: () {
                          setState(() {
                            selectedMethod = method;
                          });
                        },
                      ),
                    );
                  },
                ),
              );
            }
            return const Center(
              child: Text('No payout methods available'),
            );
          },
        ),
        Dimens.space(2),
        PrimaryButton(
          borderRadius: 15,
          text: 'Add Payout Method',
          isLoading: false,
          color: AppColors.neutral100,
          textColor: AppColors.neutral600,
          onTap: () {
            NavigatorHelper.to(const AddPayoutMethodView());
          },
        ),
        Dimens.space(2),
        BlocConsumer<WithdrawalBloc, WithdrawalState>(
          listener: (context, state) {
            if (state is WithdrawalFailure) {
              Toast.showError(state.message);
            }
            if (state is WithdrawalSuccess) {
              AppPopup.showDialogSheet(
                  context,
                  SuccessDialog(
                    title: 'Success',
                    subtext: 'Withdrawal request has been sent successfully.',
                    onProceed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ));

              Navigator.of(context).pop();
            }

            // TODO: implement listener
          },
          builder: (context, state) {
            return PrimaryButton(
                text: 'Withdraw',
                isDisabled: selectedMethod == null,
                isLoading:
                    context.watch<WithdrawalBloc>().state is WithdrawalLoading,
                onTap: () {
                  context
                      .read<WithdrawalBloc>()
                      .add(WithdrawMoneyEvent(selectedMethod!, amount));
                });
          },
        ),
      ],
    ));
  }
}
