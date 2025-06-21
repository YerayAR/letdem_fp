import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/presentation/empty_states/empty_payout.view.dart';
import 'package:letdem/features/payout_methods/presentation/views/add/add_payout.view.dart';
import 'package:letdem/features/payout_methods/presentation/widgets/payout_item.widget.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/withdrawals/presentation/widgets/amount_input.widget.dart';
import 'package:letdem/features/withdrawals/withdrawal_bloc.dart';

import '../../../../common/popups/popup.dart';
import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/button.dart';
import '../../../../infrastructure/services/res/navigator.dart';
import '../../../../infrastructure/toast/toast/toast.dart';

class WithdrawView extends StatefulWidget {
  const WithdrawView({super.key});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
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
          title: context.l10n.withdraw,
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
            boxShadow: const [],
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
              return Center(
                child: Text(context.l10n.noPayoutMethodsAvailable),
              );
            }
            if (state is PayoutMethodSuccess) {
              if (state.methods.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Dimens.space(5),
                    const EmptyPayoutMethodView(),
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
            return Center(
              child: Text(context.l10n.noPayoutMethodsAvailable),
            );
          },
        ),
        Dimens.space(2),
        PrimaryButton(
          borderRadius: 15,
          text: context.l10n.addPayoutMethod,
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
            print('Withdrawal state: $state');
            if (state is WithdrawalFailure) {
              Toast.showError(state.message);
            }
            if (state is WithdrawalSuccess) {
              context.read<UserBloc>().add(FetchUserInfoEvent());
              AppPopup.showDialogSheet(
                  NavigatorHelper.navigatorKey.currentContext!,
                  SuccessDialog(
                    title: context.l10n.success,
                    subtext: context.l10n.withdrawalRequestSuccess,
                    onProceed: () {
                      NavigatorHelper.pop();
                      NavigatorHelper.pop();
                      NavigatorHelper.pop();
                    },
                  ));
            }

            // TODO: implement listener
          },
          builder: (context, state) {
            return PrimaryButton(
                text: context.l10n.withdraw,
                isDisabled: selectedMethod == null,
                isLoading:
                    context.watch<WithdrawalBloc>().state is WithdrawalLoading,
                onTap: () {
                  if (context.userProfile!.earningAccount!.availableBalance <=
                      0) {
                    Toast.showError(
                        'You do not have enough balance to withdraw');
                    return;
                  }

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
