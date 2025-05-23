import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/constants/ui/colors.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/views/app/publish_space/screens/publish_space.view.dart';

// Mock data models

enum ReservedStatus {
  confirmed,
  pending,
  reserved,
  canceled,
  expired,
}

ReservedStatus reservedStatusFromString(String status) {
  return ReservedStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == status.toLowerCase(),
    orElse: () => ReservedStatus.pending,
  );
}

String reservedStatusToString(ReservedStatus status) {
  return status.name.toUpperCase();
}

class Order {
  final String price;
  final PublishSpaceType type;
  final ReservedStatus status;
  final String street;
  final DateTime created;

  Order({
    required this.price,
    required this.type,
    required this.status,
    required this.street,
    required this.created,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      price: json['price'],
      type: getEnumFromText(json['type'], ""),
      status: reservedStatusFromString(json['status']),
      street: json['street'],
      created: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'type': type,
      'status': reservedStatusToString(status),
      'street': street,
      'created': created.toIso8601String(),
    };
  }
}

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
      appBar: AppBar(
        title: const Text(
          'Orders',
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<UserBloc, UserState>(
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
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(order: order);
                },
              ),
            );
          }

          return const Center(
            child: Text('Error loading orders'),
          );
        },
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
          SvgPicture.asset(
            getSpaceTypeIcon(order.type),
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
                      order.price,
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
                      _formatDate(order.created),
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
          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€${double.parse(order.price).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(order.status),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIconBackgroundColor(Order order) {
    switch (order.status) {
      case ReservedStatus.canceled:
        return AppColors.red50;
      case ReservedStatus.pending:
        return AppColors.neutral50;
      case ReservedStatus.confirmed:
        return AppColors.primary50;
      case ReservedStatus.reserved:
        return AppColors.red50;
      case ReservedStatus.expired:
        // TODO: Handle this case.
        return AppColors.red50;
    }
  }

  Color _getIconColor(Order order) {
    return Colors.white;
  }

  Widget _buildStatusChip(ReservedStatus status) {
    late Color backgroundColor;
    late Color textColor;
    late String text;

    if (status case ReservedStatus.reserved || ReservedStatus.pending) {
      backgroundColor = AppColors.green50;
      textColor = AppColors.green500;
      text = 'Active';
    } else if (status case ReservedStatus.confirmed) {
      backgroundColor = AppColors.primary50;
      textColor = AppColors.primary500;
      text = 'Confirmed';
    } else if (status case ReservedStatus.canceled) {
      backgroundColor = AppColors.red50;
      textColor = AppColors.red500;
      text = 'Expired';
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 5) {
      return 'Just now';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 14) {
      return '1 week ago';
    } else if (difference.inDays < 21) {
      return '2 weeks ago';
    } else if (difference.inDays < 30) {
      return '3 weeks ago';
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
            child: Icon(
              Iconsax.notification5,
              size: 40,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You have not made any orders yet.\nStart exploring and make your first order!',
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
