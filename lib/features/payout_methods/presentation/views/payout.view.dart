import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/popup.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/payout_methods/payout_method_bloc.dart';
import 'package:letdem/features/payout_methods/presentation/empty_states/empty_payout.view.dart';
import 'package:letdem/features/payout_methods/presentation/views/add/add_payout.view.dart';
import 'package:letdem/features/payout_methods/presentation/widgets/payout_item.widget.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  int? selectedMethodIndex;
  bool showOptionsBottomSheet = false;
  bool showDeleteConfirmDialog = false;

  @override
  initState() {
    super.initState();
    // Fetch payout methods when the screen is initialized
    context.read<PayoutMethodBloc>().add(FetchPayoutMethods());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<PayoutMethodBloc, PayoutMethodState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return StyledBody(
                isBottomPadding: false,
                children: [
                  StyledAppBar(
                    title: context.l10n.payoutMethods,
                    onTap: () => Navigator.of(context).pop(),
                    icon: Icons.close,
                  ),
                  Dimens.space(2),
                  Expanded(
                    child: state is PayoutMethodLoading ||
                            state is PayoutMethodInitial
                        ? const Center(
                            child: CupertinoActivityIndicator(),
                          )
                        : state is PayoutMethodFailure
                            ? Center(
                                child: Text(
                                  state.message,
                                  style: Typo.mediumBody.copyWith(
                                    color: AppColors.red500,
                                  ),
                                ),
                              )
                            :

                            //     empty state
                            state is PayoutMethodSuccess &&
                                    state.methods.isEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const EmptyPayoutMethodView(),
                                      Dimens.space(2),
                                      _buildAddPayoutMethodButton(),
                                    ],
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    itemCount: (state as PayoutMethodSuccess)
                                            .methods
                                            .length +
                                        1, // +1 for the add button
                                    itemBuilder: (context, index) {
                                      if (index == (state).methods.length) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: _buildAddPayoutMethodButton(),
                                        );
                                      }

                                      final method = (state).methods[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: _buildPayoutMethodCard(
                                            method, index),
                                      );
                                    },
                                  ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMethodCard(PayoutMethod method, int index) {
    return OptionItem(
      method: method,
      onTap: () {
        AppPopup.showBottomSheet(
            context,
            Container(
              padding: EdgeInsets.symmetric(horizontal: Dimens.defaultMargin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.payoutMethodOptions,
                        style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      Dimens.space(1),
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
                  Dimens.space(2),
                  GestureDetector(
                    onTap: () {
                      context.read<PayoutMethodBloc>().add(
                            DeletePayoutMethod(method.id),
                          );
                      NavigatorHelper.pop();
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
                        Dimens.space(1),
                        Text(context.l10n.delete,
                            style: Typo.largeBody.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                  Dimens.space(2),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildAddPayoutMethodButton() {
    return PrimaryButton(
      text: context.l10n.addPayoutMethod,
      background: AppColors.primary500,
      textColor: Colors.white,
      onTap: () {
        NavigatorHelper.to(const AddPayoutMethodView());
      },
    );
  }
}
