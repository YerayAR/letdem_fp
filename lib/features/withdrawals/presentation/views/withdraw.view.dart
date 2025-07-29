import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/popups/success_dialog.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/price.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/presentation/empty_states/empty_payout.view.dart';
import 'package:letdem/features/payout_methods/presentation/views/add/add_payout.view.dart';
import 'package:letdem/features/payout_methods/presentation/widgets/payout_item.widget.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/features/withdrawals/presentation/widgets/amount_input.widget.dart';
import 'package:letdem/features/withdrawals/withdrawal_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

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
                onChange: (value) {},
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
          if (state is WithdrawalFinished) {
            // context.read<UserBloc>().add(FetchUserInfoEvent());

            AppPopup.showDialogSheet(
                NavigatorHelper.navigatorKey.currentContext!,
                SuccessDialog(
                  title: context.l10n.success,
                  subtext: context.l10n.withdrawalRequestSuccess,
                  onProceed: () {
                    // context.read<WithdrawalBloc>().add(FetchWithdrawals());
                    NavigatorHelper.pop();
                    NavigatorHelper.pop();
                    NavigatorHelper.pop();
                  },
                ));
          }

          // TODO: implement listener
        }, builder: (context, state) {
          final constants =
              context.userProfile?.constantsSettings.withdrawalAmount;

          final availableBalance =
              context.userProfile?.earningAccount!.availableBalance ?? 0;

          final amount =
              context.userProfile?.earningAccount?.availableBalance ?? 0;

          return Column(
            children: [
              PrimaryButton(
                text: context.l10n.withdraw,
                isDisabled: selectedMethod == null ||
                    amount < (constants?.minimum ?? 0) ||
                    amount > (constants?.maximum ?? 0) ||
                    amount > availableBalance,
                isLoading: state is WithdrawalLoading,
                onTap: () {
                  if (amount < (constants?.minimum ?? 0)) {
                    Toast.showError(
                      context.l10n.minWithdrawalToast(
                          (constants?.minimum ?? 0).formatPrice(context)),
                    );
                    return;
                  }

                  if (amount > (constants?.maximum ?? 0)) {
                    Toast.showError(
                      context.l10n.maxWithdrawalToast(
                          (constants?.maximum ?? 0).formatPrice(context)),
                    );
                    return;
                  }

                  if (amount > availableBalance) {
                    Toast.showError(context.l10n.exceedsBalanceToast);
                    return;
                  }

                  context.read<WithdrawalBloc>().add(
                        WithdrawMoneyEvent(selectedMethod!, amount),
                      );
                },
              ),
              Dimens.space(1),
              if (availableBalance < (constants?.minimum ?? 0))
                Text(
                  context.l10n.minWithdrawalAmountError(
                      (constants?.minimum ?? 0).formatPrice(context)),
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.red500,
                    fontSize: 13,
                  ),
                ),
              if (availableBalance >= (constants?.maximum ?? 0))
                Text(
                  context.l10n.maxWithdrawalAmountError(
                      (constants?.maximum ?? 0).formatPrice(context)),
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.red500,
                    fontSize: 13,
                  ),
                ),
            ],
          );
        }),
      ],
    ));
  }
}
