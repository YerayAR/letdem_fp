import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/activities/activities_state.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/infrastructure/toast/toast/toast.dart';

import '../../../models/user.model.dart';

class ReservationHistory extends StatefulWidget {
  const ReservationHistory({super.key});

  @override
  State<ReservationHistory> createState() => _ReservationHistoryState();
}

class _ReservationHistoryState extends State<ReservationHistory> {
  @override
  initState() {
    super.initState();
    context.read<UserBloc>().add(FetchReservationHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            Toast.showError(state.error);
          }
        },
        builder: (context, state) {
          return StyledBody(
            children: [
              StyledAppBar(
                title: context.l10n.reservations,
                onTap: () {
                  NavigatorHelper.pop();
                },
                icon: Icons.close,
              ),
              Dimens.space(3),
              Expanded(
                child: state is UserLoaded
                    ? state.isUpdateLoading
                        ? const ReservationPaymentsLoadingView()
                        :
                        // If no reservations, show empty state
                        (state).reservationHistory.isEmpty
                            ? const EmptyReservationPaymentsView()
                            : RefreshIndicator(
                                onRefresh: () async {
                                  context
                                      .read<UserBloc>()
                                      .add(FetchReservationHistoryEvent());
                                },
                                child: ListView.builder(
                                  itemCount: state.reservationHistory.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        state.reservationHistory[index];
                                    return ReservationPaymentCard(
                                        payment: item);
                                  },
                                ),
                              )
                    : const Center(
                        child: CupertinoActivityIndicator(),
                      ),
              ),
              // Visa Card Item (Default)
            ],
          );
        },
      ),
    );
  }
}

class ReservationPaymentCard extends StatelessWidget {
  final UserReservationPayments payment;

  const ReservationPaymentCard({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // color: _getIconBackgroundColor(payment.type),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: SvgPicture.asset(
                getSpaceTypeIcon(payment.type),
                width: 34,
                height: 34,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.street,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      getSpaceTypeText(payment.type, context),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _formatDate(payment.created, context),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${double.parse(payment.price).toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(payment.status, context),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconBackgroundColor(PublishSpaceType type) {
    return AppColors.neutral400;
  }

  Widget _buildStatusChip(ReservedSpaceStatus status, BuildContext context) {
    late Color backgroundColor;
    late Color textColor;
    late String text;

    // pending,
    // reserved,
    // confirmed,
    // expired,
    // cancelled;

    switch (status) {
      case ReservedSpaceStatus.expired:
        backgroundColor = AppColors.neutral50;
        textColor = AppColors.neutral400;
        text = context.l10n.expired;
        break;
      case ReservedSpaceStatus.confirmed:
        backgroundColor = AppColors.primary50;
        textColor = AppColors.primary500;
        text = context.l10n.confirmed;
        break;
      case ReservedSpaceStatus.reserved:
        backgroundColor = AppColors.green50;
        textColor = AppColors.green500;
        text = context.l10n.reserved;
        break;
      case ReservedSpaceStatus.pending:
        backgroundColor = AppColors.green50;
        textColor = AppColors.green500;
        text = context.l10n.pending;
        break;
      case ReservedSpaceStatus.cancelled:
        backgroundColor = AppColors.red50;
        textColor = AppColors.red500;
        text = context.l10n.cancelled;
        break;
      default: // ReservedSpaceStatus.expired
        backgroundColor = AppColors.neutral50;
        textColor = AppColors.neutral400;
        text = status.name.toLowerCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);

    print(
        'Date: $date, Now: $now, Difference: ${difference.inDays} days, ${difference.inHours} hours, ${difference.inMinutes} minutes');

    if (difference.inMinutes < 5) {
      return context.l10n.justNow;
    } else if (difference.inDays == 0) {
      return context.l10n.today;
    } else if (difference.inDays == 1) {
      return context.l10n.yesterday;
    } else if (difference.inDays < 7) {
      return context.l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 14) {
      return context.l10n.oneWeekAgo;
    } else if (difference.inDays < 21) {
      return context.l10n.twoWeeksAgo;
    } else if (difference.inDays < 30) {
      return context.l10n.threeWeeksAgo;
    } else {
      return '${date.day} ${_getMonthName(date.month)}. ${date.year}';
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

// Loading state widget
class ReservationPaymentsLoadingView extends StatelessWidget {
  const ReservationPaymentsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const ReservationPaymentShimmerCard();
      },
    );
  }
}

class ReservationPaymentShimmerCard extends StatelessWidget {
  const ReservationPaymentShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shimmer icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
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
                  width: 140,
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
                height: 24,
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

// Empty state widget
class EmptyReservationPaymentsView extends StatelessWidget {
  const EmptyReservationPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              AppAssets.card, // You may need to update this icon
              width: 40,
              height: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.noPaymentsYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.noPaymentsDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
