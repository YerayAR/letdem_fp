import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/commons/presentations/widgets/date_time_display.widget.dart';
import 'package:letdem/features/withdrawals/withdrawal_bloc.dart';
import 'package:letdem/models/withdrawals/withdrawal.model.dart';

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
      body: StyledBody(
        children: [
          StyledAppBar(
            title: context.l10n.withdrawals,
            onTap: () => Navigator.of(context).pop(),
            icon: Icons.close,
          ),
          Dimens.space(2),
          BlocConsumer<WithdrawalBloc, WithdrawalState>(
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
                  return const Expanded(
                      child: Center(child: EmptyWithdrawalView()));
                }
                return Expanded(
                    child:
                        WithdrawalListWidget(withdrawals: state.withdrawals));
              } else if (state is WithdrawalFailure) {
                return WithdrawalErrorView(
                  message: state.message,
                  onRetry: () {
                    context
                        .read<WithdrawalBloc>()
                        .add(const FetchWithdrawals());
                  },
                );
              }
              return const WithdrawalLoadingView();
            },
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.05),
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
            child: SvgPicture.asset(
              AppAssets.card,
              width: 24,
              height: 24,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // maskedPayoutMethod last 5 digits if available

                  context.l10n.withdrawalToBank(
                    "...${withdrawal.maskedPayoutMethod.substring(withdrawal.maskedPayoutMethod.length - 4)}",
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                DateTimeDisplay(date: withdrawal.created)
              ],
            ),
          ),
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${withdrawal.amount.abs().toStringAsFixed(2)}€',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(withdrawal.status, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(WithdrawalStatus status, BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case WithdrawalStatus.completed:
        backgroundColor = AppColors.green50;
        textColor = AppColors.green500;
        text = context.l10n.successful;
        break;
      case WithdrawalStatus.pending:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[600]!;
        text = context.l10n.pending;
        break;
      case WithdrawalStatus.failed:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[600]!;
        text = context.l10n.failed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class WithdrawalLoadingView extends StatelessWidget {
  const WithdrawalLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return const WithdrawalShimmerCard();
        },
      ),
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
            child: SvgPicture.asset(AppAssets.card,
                width: 40, height: 40, color: AppColors.primary500),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.noWithdrawalsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.withdrawalHistoryMessage,
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
          Text(
            context.l10n.somethingWentWrong,
            style: const TextStyle(
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
            child: Text(context.l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}
