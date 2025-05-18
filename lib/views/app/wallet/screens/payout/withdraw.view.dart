import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/constants/ui/typo.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';
import 'package:letdem/services/res/navigator.dart';
import 'package:letdem/views/app/wallet/screens/payout/payout.view.dart';

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
              Center(
                child: Text(
                  'Amount to receive',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),
              Dimens.space(1),
              Text(
                '€${context.userProfile!.earningAccount?.balance}',
                style: Typo.heading3
                    .copyWith(fontWeight: FontWeight.w800, fontSize: 36),
                textAlign: TextAlign.center,
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
                  itemCount: (state).methods.length, // +1 for the add button
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
        PrimaryButton(
          text: 'Withdraw',
          isLoading: false,
          onTap: () {},
        ),
      ],
    ));
  }
}
