import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/features/withdrawals/withdrawal_bloc.dart';
import 'package:letdem/models/withdrawals/withdrawal.bloc.dart';

class WithdrawListView extends StatefulWidget {
  const WithdrawListView({super.key});

  @override
  State<WithdrawListView> createState() => _WithdrawListViewState();
}

class _WithdrawListViewState extends State<WithdrawListView> {
  @override
  void initState() {
    context.read<WithdrawalBloc>().add(const FetchWithdrawals());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Withdrawals',
        ),
      ),
      body: BlocConsumer<WithdrawalBloc, WithdrawalState>(
        listener: (context, state) {
          if (state is WithdrawalFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WithdrawalLoading) {
            return const WithdrawalLoadingView();
          } else if (state is WithdrawalSuccess) {
            if (state.withdrawals.isEmpty) {
              return const EmptyWithdrawalView();
            }
            return StyledBody(children: [
              Expanded(
                  child: WithdrawalListWidget(withdrawals: state.withdrawals))
            ]);
          } else if (state is WithdrawalFailure) {
            return WithdrawalErrorView(
              message: state.message,
              onRetry: () {
                context.read<WithdrawalBloc>().add(const FetchWithdrawals());
              },
            );
          }
          return const WithdrawalLoadingView();
        },
      ),
    );
  }
}

class WithdrawalListWidget extends StatelessWidget {
  final List<Withdrawal> withdrawals;

  const WithdrawalListWidget({
    super.key,
    required this.withdrawals,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WithdrawalBloc>().add(const FetchWithdrawals());
      },
      child: ListView.separated(
        itemCount: withdrawals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final withdrawal = withdrawals[index];
          return WithdrawalCard(withdrawal: withdrawal);
        },
      ),
    );
  }
}

class WithdrawalCard extends StatelessWidget {
  final Withdrawal withdrawal;

  const WithdrawalCard({
    super.key,
    required this.withdrawal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bank icon
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.neutral50,
            child: Icon(
              Iconsax.card5,
              color: AppColors.neutral500,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Withdrawal to Bank ${withdrawal.maskedPayoutMethod}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(withdrawal.created),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${withdrawal.amount.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(withdrawal.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(WithdrawalStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case WithdrawalStatus.completed:
        backgroundColor = AppColors.green50;
        textColor = AppColors.green500;
        text = 'Successful';
        break;
      case WithdrawalStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[600]!;
        text = 'Pending';
        break;
      case WithdrawalStatus.failed:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[600]!;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Just now';
    } else if (dateOnly == yesterday) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day} ${_getMonthName(date.month)}, ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class WithdrawalLoadingView extends StatelessWidget {
  const WithdrawalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const WithdrawalShimmerCard();
      },
    );
  }
}

class WithdrawalShimmerCard extends StatelessWidget {
  const WithdrawalShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shimmer icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          // Shimmer details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Shimmer amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 16,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 20,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyWithdrawalView extends StatelessWidget {
  const EmptyWithdrawalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Iconsax.bank,
              size: 40,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Withdrawals Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your withdrawal history will appear here\nwhenever you make a withdrawal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class WithdrawalErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WithdrawalErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.red[50],
            child: Icon(
              Iconsax.warning_2,
              size: 40,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
