import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/marketplace_data.dart';
import 'package:letdem/features/marketplace/presentation/bloc/order_history/order_history_cubit.dart';
import 'package:letdem/features/marketplace/presentation/bloc/order_history/order_history_state.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              OrderHistoryCubit(MarketplaceRepositoryImpl())
                ..loadOrderHistory(),
      child: const _OrderHistoryContent(),
    );
  }
}

class _OrderHistoryContent extends StatelessWidget {
  const _OrderHistoryContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Historial de compras',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.neutral900),
      ),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        builder: (context, state) {
          if (state is OrderHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 64, color: AppColors.red600),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar historial',
                    style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Typo.mediumBody.copyWith(
                      color: AppColors.neutral600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            context
                                .read<OrderHistoryCubit>()
                                .refreshOrderHistory(),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is OrderHistoryLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.shopping_bag,
                      size: 64,
                      color: AppColors.neutral300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes compras aún',
                      style: Typo.largeBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus compras aparecerán aquí',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  () => context.read<OrderHistoryCubit>().refreshOrderHistory(),
              child: ListView(
                padding: EdgeInsets.all(Dimens.defaultMargin),
                children: [
                  _buildStatsCard(state.stats),
                  Dimens.space(2),
                  Text(
                    'Órdenes',
                    style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Dimens.space(2),
                  ...state.orders.map(
                    (order) => _buildOrderCard(context, order),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsCard(OrderHistoryStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary500, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.wallet_35, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Resumen',
                style: Typo.largeBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Órdenes totales',
                  stats.totalOrders.toString(),
                  Iconsax.shopping_cart,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total gastado',
                  '\$${stats.totalSpent.toStringAsFixed(2)}',
                  Iconsax.money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Puntos usados',
                  '${stats.totalPointsUsed} pts',
                  Iconsax.ticket_discount,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total ahorrado',
                  '\$${stats.totalSaved.toStringAsFixed(2)}',
                  Iconsax.tag_2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.star_1, color: AppColors.secondary500, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Puntos actuales: ${stats.currentPoints}',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Typo.largeBody.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Text(label, style: Typo.smallBody.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Orden #${order.id.substring(0, 8)}',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 14,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(order.created),
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.itemsCount} producto(s)',
                      style: Typo.mediumBody,
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: Typo.largeBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                ),
                if (order.usedPoints) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.ticket_discount,
                          size: 14,
                          color: AppColors.green600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Usaste ${order.pointsUsedAmount} puntos • Ahorraste \$${order.pointsDiscount.toStringAsFixed(2)}',
                          style: Typo.smallBody.copyWith(
                            color: AppColors.green700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (order.items.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productos',
                    style: Typo.mediumBody.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items
                      .take(3)
                      .map((item) => _buildOrderItemRow(item)),
                  if (order.items.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${order.items.length - 3} producto(s) más',
                        style: Typo.smallBody.copyWith(
                          color: AppColors.primary500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(8),
              image:
                  item.productImage.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(item.productImage),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                item.productImage.isEmpty
                    ? Icon(Iconsax.box, color: AppColors.neutral300)
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.storeName,
                  style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.hasDiscount)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '30% OFF',
                      style: Typo.smallBody.copyWith(
                        color: AppColors.green700,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item.quantity}',
                style: Typo.smallBody.copyWith(color: AppColors.neutral600),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'PAID':
      case 'COMPLETED':
        backgroundColor = AppColors.green50;
        textColor = AppColors.green700;
        break;
      case 'PROCESSING':
        backgroundColor = AppColors.secondary50;
        textColor = AppColors.secondary600;
        break;
      case 'PENDING':
        backgroundColor = AppColors.neutral50;
        textColor = AppColors.neutral700;
        break;
      case 'CANCELLED':
        backgroundColor = AppColors.red50;
        textColor = AppColors.red700;
        break;
      default:
        backgroundColor = AppColors.neutral50;
        textColor = AppColors.neutral700;
    }

    final order = Order(
      id: '',
      userId: '',
      userEmail: '',
      status: status,
      subtotal: 0,
      pointsDiscount: 0,
      total: 0,
      usedPoints: false,
      pointsUsedAmount: 0,
      items: [],
      itemsCount: 0,
      created: DateTime.now(),
      modified: DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        order.statusDisplay,
        style: Typo.smallBody.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
