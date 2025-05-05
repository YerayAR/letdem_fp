import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/constants/ui/dimens.dart';
import 'package:letdem/global/widgets/appbar.dart';
import 'package:letdem/global/widgets/body.dart';
import 'package:letdem/global/widgets/button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Set to true for the populated view with €700.56, false for empty €0.00 view
  bool hasTransactions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: StyledBody(
          isBottomPadding: false,
          children: [
            StyledAppBar(
              title: 'Earnings',
              onTap: () {
                Navigator.of(context).pop();
              },
              icon: Icons.close,
            ),
            Dimens.space(2),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary600,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8A3FFC).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Wallet Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.visibility_off,
                          color: Colors.white.withOpacity(0.5),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasTransactions ? '€700.56' : '€0.00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Withdraw',
                      background: AppColors.primary50,
                      textColor: AppColors.primary500,
                    )
                  ],
                ),
              ),
            ),
            Dimens.space(3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(IconlyBold.location, 'Orders'),
                  SizedBox(width: 16),
                  _buildActionButton(Iconsax.card5, 'Withdrawals'),
                  SizedBox(width: 16),
                  _buildActionButton(Iconsax.bank, 'Payouts'),
                ],
              ),
            ),
            Dimens.space(4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasTransactions)
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: Color(0xFF8A3FFC),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Dimens.space(3),
            Expanded(
              child: hasTransactions
                  ? _buildTransactionsList()
                  : _buildEmptyTransactionsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.neutral50,
                  child: Icon(
                    icon,
                    color: Colors.blueGrey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = [
      Transaction(
        type: TransactionType.payment,
        amount: 3.00,
        date: DateTime(2025, 1, 12, 8, 30),
        description: 'Payment Received for Space',
      ),
      Transaction(
        type: TransactionType.withdrawal,
        amount: -6.00,
        date: DateTime(2025, 1, 12, 8, 30),
        description: 'Withdrawal',
      ),
      Transaction(
        type: TransactionType.payment,
        amount: 3.00,
        date: DateTime(2025, 1, 12, 8, 30),
        description: 'Payment Received for Space',
      ),
      Transaction(
        type: TransactionType.payment,
        amount: 3.00,
        date: DateTime(2025, 1, 12, 8, 30),
        description: 'Payment Received for Space',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: transaction.type == TransactionType.payment
                            ? Color(0xFFE6F7EE)
                            : Color(0xFFFFEEEE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        transaction.type == TransactionType.payment
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: transaction.type == TransactionType.payment
                            ? Color(0xFF00A86B)
                            : Color(0xFFFF4D4F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('dd MMM. yyyy').format(transaction.date)} · ${DateFormat('HH:mm').format(transaction.date)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      transaction.amount > 0
                          ? '+€${transaction.amount.toStringAsFixed(2)}'
                          : '-€${(-transaction.amount).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.amount > 0
                            ? Color(0xFF00A86B)
                            : Color(0xFFFF4D4F),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Dimens.space(1),
                Divider(
                  color: AppColors.neutral50,
                  thickness: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTransactionsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transactions history will be listed here when you have any to show.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.5,
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
