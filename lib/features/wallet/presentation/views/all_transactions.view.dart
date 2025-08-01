import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/popups/date_time_picker.widget.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/wallet/presentation/views/wallet.view.dart';
import 'package:letdem/features/wallet/wallet_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/transactions/transactions.model.dart';

class AllTransactionsView extends StatefulWidget {
  const AllTransactionsView({super.key});

  @override
  State<AllTransactionsView> createState() => _AllTransactionsViewState();
}

class _AllTransactionsViewState extends State<AllTransactionsView> {
  DateTime _toDate = DateTime.now();

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));

  initialization() {
    // Initializing the date range for transactions
    context.read<WalletBloc>().add(FetchTransactionsEvent(TransactionParams(
          startDate: _fromDate,
          endDate: _toDate,
          pageSize: 50,
          page: 1,
        )));
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        isBottomPadding: false,
        children: [
          StyledAppBar(
            onTap: () {
              NavigatorHelper.pop();

              context
                  .read<WalletBloc>()
                  .add(FetchTransactionsEvent(TransactionParams(
                    startDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    endDate: DateTime.now().add(const Duration(days: 1)),
                    pageSize: 50,
                    page: 1,
                  )));
            },
            title: context.l10n.transactionTitle,
            icon: Iconsax.close_circle5,
          ),
          Expanded(
            child: BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                if (state is WalletLoading) {
                  return const WalletLoadingComponent();
                } else if (state is WalletSuccess) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          PlatformDatePickerButton(
                              label: context.l10n.fromDate,
                              initialDate: _fromDate,
                              maximumDate: _toDate,
                              minimumDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              onDateSelected: (date) {
                                setState(() {
                                  if (!date.isAfter(_toDate)){
                                    _fromDate = date;
                                  }
                                });
                                context.read<WalletBloc>().add(
                                        FetchTransactionsEvent(
                                            TransactionParams(
                                      startDate: _fromDate,
                                      endDate: _toDate,
                                      pageSize: 50,
                                      page: 1,
                                    )));
                              }),
                          Dimens.space(2),
                          PlatformDatePickerButton(
                              label: context.l10n.toDate,
                              maximumDate: DateTime.now(),
                              minimumDate: _fromDate,
                              initialDate: _toDate,
                              onDateSelected: (date) {
                                setState(() {
                                  if (!date.isBefore(_fromDate)){
                                    _toDate = date;
                                  }
                                });
                                context.read<WalletBloc>().add(
                                        FetchTransactionsEvent(
                                            TransactionParams(
                                      startDate: _fromDate,
                                      endDate: _toDate,
                                      pageSize: 50,
                                      page: 1,
                                    )));
                              }),
                        ],
                      ),
                      Dimens.space(3),
                      Expanded(child: TransactionList()),
                    ],
                  );
                } else if (state is WalletFailure) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return Center(child: Text(context.l10n.noTransactionsYet));
              },
            ),
          ),
        ],
      ),
    );
  }
}
