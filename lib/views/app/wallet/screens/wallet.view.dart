import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/constants/ui/assets.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/extenstions/user.dart';
import 'package:letdem/features/wallet/repository/transaction.repository.dart';
import 'package:letdem/features/wallet/wallet_bloc.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  initState() {
    super.initState();
    context.read<WalletBloc>().add(FetchTransactionsEvent(TransactionParams(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          pageSize: 100,
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
            title: 'Earnings',
            onTap: () => Navigator.of(context).pop(),
            icon: Icons.close,
          ),
          Dimens.space(2),
          WalletBalanceCard(
              balance: context.userProfile!.earningAccount!.balance),
          Dimens.space(3),
          const WalletActionsRow(),
          Dimens.space(4),
          TransactionHeader(hasTransactions: false),
          Dimens.space(3),
          BlocConsumer<WalletBloc, WalletState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              if (state is WalletLoading) {
                return const Center(
                    child: Expanded(
                        child: Center(child: CircularProgressIndicator())));
              } else if (state is WalletFailure) {
                return Expanded(
                    child: Center(child: const EmptyTransactionsView()));
              } else if (state is WalletSuccess) {
                if (state.transactions.isEmpty) {
                  return Center(child: const EmptyTransactionsView());
                }
                return Expanded(child: Center(child: TransactionList()));
              }
              return Expanded(
                  child: Center(child: const EmptyTransactionsView()));
            },
          ),
        ],
      ),
    );
  }
}

class WalletBalanceCard extends StatelessWidget {
  final double balance;

  const WalletBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary600,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A3FFC).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              top: 0, right: 0, child: SvgPicture.asset(AppAssets.ellipse)),
          Positioned(
              bottom: 0,
              left: 0,
              child: SvgPicture.asset(AppAssets.ellipseLeft)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.visibility_off,
                        color: Colors.white.withOpacity(0.5), size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: balance),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, _) {
                    return Text(
                      '€${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Withdraw',
                  background: AppColors.primary50,
                  textColor: AppColors.primary500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletActionsRow extends StatelessWidget {
  const WalletActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ActionButton(icon: IconlyBold.location, label: 'Orders'),
        SizedBox(width: 16),
        _ActionButton(icon: Iconsax.card5, label: 'Withdrawals'),
        SizedBox(width: 16),
        _ActionButton(icon: Iconsax.bank, label: 'Payouts'),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              child: Icon(icon, color: Colors.blueGrey.shade700, size: 24),
            ),
            const SizedBox(height: 15),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class TransactionHeader extends StatelessWidget {
  final bool hasTransactions;

  const TransactionHeader({super.key, required this.hasTransactions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Transaction History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (hasTransactions)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(
                  color: Color(0xFF8A3FFC),
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          ),
      ],
    );
  }
}

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView.builder(
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
                      color: tx.type == TransactionType.payment
                          ? const Color(0xFFE6F7EE)
                          : const Color(0xFFFFEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tx.type == TransactionType.payment
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: tx.type == TransactionType.payment
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
                        Text(tx.description,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('dd MMM. yyyy').format(tx.date)} · ${DateFormat('HH:mm').format(tx.date)}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    tx.amount > 0
                        ? '+€${tx.amount.toStringAsFixed(2)}'
                        : '-€${(-tx.amount).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: tx.amount > 0
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
}

class EmptyTransactionsView extends StatelessWidget {
  const EmptyTransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No Transactions Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Your transactions history will be listed here when you have any to show.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 14, height: 1.5),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

enum TransactionType { payment, withdrawal }

class Transaction {
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;

  Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });
}
