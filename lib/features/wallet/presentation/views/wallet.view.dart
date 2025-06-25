import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/payout_methods/presentation/views/payout.view.dart';
import 'package:letdem/features/users/presentation/views/orders/orders.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/wallet/presentation/views/all_transactions.view.dart';
import 'package:letdem/features/wallet/wallet_bloc.dart';
import 'package:letdem/features/withdrawals/presentation/views/withdraw.view.dart';
import 'package:letdem/features/withdrawals/presentation/views/withdrawals.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/transactions/transactions.model.dart';
import 'package:shimmer/shimmer.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(FetchTransactionsEvent(TransactionParams(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          pageSize: 50,
          page: 1,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        isBottomPadding: false,
        children: [
          StyledAppBar(
            title: context.l10n.earnings,
            onTap: () => Navigator.of(context).pop(),
            icon: Icons.close,
          ),
          WalletBalanceCard(
              balance: context.userProfile!.earningAccount!.balance),
          Dimens.space(3),
          const WalletActionsRow(),
          Dimens.space(4),
          const TransactionHeader(),
          Dimens.space(3),
          Expanded(
            child: BlocConsumer<WalletBloc, WalletState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is WalletLoading) {
                  return const WalletLoadingComponent();
                }
                if (state is WalletFailure) {
                  return const EmptyTransactionsView();
                }
                if (state is WalletSuccess && state.transactions.isNotEmpty) {
                  return const TransactionList();
                }
                return const EmptyTransactionsView();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WalletBalanceCard extends StatefulWidget {
  final double balance;

  const WalletBalanceCard({super.key, required this.balance});

  @override
  State<WalletBalanceCard> createState() => _WalletBalanceCardState();
}

class _WalletBalanceCardState extends State<WalletBalanceCard> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildCardDecoration(),
      child: Stack(
        children: [
          _buildTopRightDecoration(),
          _buildBottomLeftDecoration(),
          _buildCardContent(),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.primary600,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF8A3FFC).withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildTopRightDecoration() {
    return Positioned(
      top: 0,
      right: 0,
      child: SvgPicture.asset(AppAssets.ellipse),
    );
  }

  Widget _buildBottomLeftDecoration() {
    return Positioned(
      bottom: 0,
      left: 0,
      child: SvgPicture.asset(AppAssets.ellipseLeft),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildBalanceDisplay(),
          const SizedBox(height: 24),
          _buildWithdrawButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.l10n.walletBalance,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: _toggleVisibility,
          child: Icon(
            isVisible ? Iconsax.eye : Iconsax.eye_slash,
            color: Colors.white.withOpacity(0.5),
            size: 16,
          ),
        ),
      ],
    );
  }

  void _toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  Widget _buildBalanceDisplay() {
    if (!isVisible) {
      return const Text(
        '****',
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      '${context.watch<UserBloc>().state is UserLoaded ? context.userProfile!.earningAccount!.balance.toStringAsFixed(2) : widget.balance.toStringAsFixed(2)} €',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return PrimaryButton(
      onTap: () {
        NavigatorHelper.to(const WithdrawView());
      },
      text: context.l10n.withdraw,
      background: AppColors.primary50,
      textColor: AppColors.primary500,
    );
  }
}

class WalletActionsRow extends StatelessWidget {
  const WalletActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: AppAssets.location,
          label: context.l10n.orders,
          onTap: () {
            NavigatorHelper.to(const OrdersListView());
          },
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: AppAssets.card,
          label: context.l10n.withdrawals,
          onTap: () {
            NavigatorHelper.to(const WithdrawListView());
          },
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: AppAssets.bank,
          label: context.l10n.payouts,
          onTap: () {
            NavigatorHelper.to(const PayoutMethodsScreen());
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;

  final VoidCallback? onTap;

  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.neutral50,
                child: SvgPicture.asset(icon, color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 15),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionHeader extends StatelessWidget {
  const TransactionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.transactionHistory,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            bool hasTransactions = false;
            if (state is WalletSuccess && state.transactions.isNotEmpty) {
              hasTransactions = true;
            }

            if (hasTransactions) {
              return TextButton(
                onPressed: () {
                  NavigatorHelper.to(AllTransactionsView());
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.l10n.seeAll,
                  style: const TextStyle(
                      color: Color(0xFF8A3FFC),
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is WalletSuccess) {
          final transactions = state.transactions;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: transactions.isEmpty
                ? const EmptyTransactionsView()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isPositiveTransaction(tx.source)
                                      ? const Color(0xFFE6F7EE)
                                      : const Color(0xFFFFEEEE),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPositiveTransaction(tx.source)
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: tx.source != TransactionType.WITHDRAW
                                      ? const Color(0xFF00A86B)
                                      : const Color(0xFFFF4D4F),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(getTransactionTypeString(tx.source),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${DateFormat('dd MMM. yyyy').format(tx.created)} · ${DateFormat('HH:mm').format(tx.created)}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                isPositiveTransaction(tx.source)
                                    ? '+ ${tx.amount.toStringAsFixed(2)}€'
                                    : '${(-tx.amount).toStringAsFixed(2)}€',
                                style: TextStyle(
                                  color: isPositiveTransaction(tx.source)
                                      ? const Color(0xFF00A86B)
                                      : const Color(0xFFFF4D4F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Dimens.space(1),
                          Divider(color: AppColors.neutral50, thickness: 1),
                        ],
                      );
                    },
                  ),
          );
        }
        return const EmptyTransactionsView();
      },
    );
  }
}

class WalletLoadingComponent extends StatelessWidget {
  const WalletLoadingComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 20,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 40,
                  child: Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.5),
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Dimens.space(1),
              Divider(color: AppColors.neutral50, thickness: 1),
            ],
          );
        },
      ),
    );
  }
}

class EmptyTransactionsView extends StatelessWidget {
  const EmptyTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.l10n.noTransactionsYet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.transactionsHistoryMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingTransactionsView extends StatelessWidget {
  const LoadingTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8A3FFC)),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.loadingTransactions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ],
      ),
    );
  }
}
