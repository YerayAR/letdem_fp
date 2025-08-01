import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/enums/PublishSpaceType.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/utils/dates.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/commons/presentations/widgets/date_time_display.widget.dart';
import 'package:letdem/models/orders/order.model.dart';

class OrdersListView extends StatefulWidget {
  const OrdersListView({super.key});

  @override
  State<OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<OrdersListView> {
  // Mock data

  @override
  initState() {
    super.initState();
    // Simulate fetching orders
    BlocProvider.of<UserBloc>(context).add(const LoadOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StyledBody(
        children: [
          StyledAppBar(
            title: context.l10n.orders,
            onTap: () => Navigator.of(context).pop(),
            icon: Icons.close,
          ),
          Dimens.space(2),
          Expanded(
            child: BlocConsumer<UserBloc, UserState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                if (state is UserLoaded) {
                  if (state.isOrdersLoading) {
                    return const OrdersLoadingView();
                  }

                  final orders = state.orders;
                  if (orders.isEmpty) {
                    return const EmptyOrdersView();
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Simulate refresh
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(order: order);
                      },
                    ),
                  );
                }

                return Center(
                  child: Text(context.l10n.errorLoadingOrders),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    super.key,
    required this.order,
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
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
                    getSpaceTypeIcon(order.type),
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
                      order.street,
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
                          getSpaceTypeText(order.type, context),
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
                    '${double.parse(order.price).toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(order.status, context),
                ],
              ),
            ],
          ),
          Divider(
            color: AppColors.neutral200.withValues(alpha: 0.2),
            thickness: 1,
            height: 24,
          ),
          Row(
            children: [
              Dimens.space(1),
              Icon(
                Iconsax.clock5,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              DateTimeDisplay(date: order.created)
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconColor(Order order) {
    return Colors.white;
  }

  Widget _buildStatusChip(ReservedStatus status, BuildContext context) {
    late Color backgroundColor;
    late Color textColor;
    late String text;

    switch (status) {
      case ReservedStatus.expired:
        backgroundColor = AppColors.neutral50;
        textColor = AppColors.neutral400;
        text = context.l10n.expired;
        break;
      case ReservedStatus.confirmed:
        backgroundColor = AppColors.primary50;
        textColor = AppColors.primary500;
        text = context.l10n.confirmed;
        break;
      case ReservedStatus.reserved:
        backgroundColor = AppColors.green50;
        textColor = AppColors.green500;
        text = context.l10n.reserved;
        break;
      case ReservedStatus.pending:
        backgroundColor = AppColors.green50;
        textColor = AppColors.green500;
        text = context.l10n.pending;
        break;
      case ReservedStatus.canceled:
        backgroundColor = AppColors.red50;
        textColor = AppColors.red500;
        text = context.l10n.cancelled;
        break;
      default:
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
}

// Loading state widget
class OrdersLoadingView extends StatelessWidget {
  const OrdersLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const OrderShimmerCard();
      },
    );
  }
}

class OrderShimmerCard extends StatelessWidget {
  const OrderShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
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
class EmptyOrdersView extends StatelessWidget {
  const EmptyOrdersView({super.key});

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
              AppAssets.location,
              width: 40,
              height: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.noOrdersYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.noOrdersDescription,
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
