import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_event.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_state.dart';
import 'package:letdem/features/marketplace/models/cart_item.model.dart';
import 'package:letdem/features/marketplace/presentation/views/cart/cart_checkout.view.dart';
import 'package:letdem/features/marketplace/presentation/views/cart/cart_redeem_type_selection.view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.neutral600),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Carrito de Compras',
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox();
              return IconButton(
                icon: Icon(Iconsax.trash, color: AppColors.red500),
                onPressed: () {
                  _showClearCartDialog(context);
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState.isEmpty) {
            return _buildEmptyCart(context);
          }

          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              final availablePoints = userState is UserLoaded ? userState.user.totalPoints : 0;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        return _CartItemCard(
                          item: item,
                          availablePoints: availablePoints,
                          totalPointsNeeded: cartState.totalPointsNeeded,
                        );
                      },
                    ),
                  ),
                  _CartSummary(
                    cartState: cartState,
                    availablePoints: availablePoints,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.shopping_cart,
                size: 80,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu carrito está vacío',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega productos para comenzar tu compra',
              style: Typo.mediumBody.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Explorar productos',
                style: Typo.mediumBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '¿Vaciar carrito?',
          style: Typo.largeBody.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Se eliminarán todos los productos del carrito',
          style: Typo.mediumBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: Typo.mediumBody.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCartEvent());
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Vaciar',
              style: Typo.mediumBody.copyWith(
                color: AppColors.red500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final int availablePoints;
  final int totalPointsNeeded;

  const _CartItemCard({
    required this.item,
    required this.availablePoints,
    required this.totalPointsNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Iconsax.box,
                      color: AppColors.primary500,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Typo.mediumBody.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${item.price.toStringAsFixed(2)} c/u',
                        style: Typo.smallBody.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Iconsax.close_circle, color: AppColors.neutral400),
                  onPressed: () {
                    context.read<CartBloc>().add(RemoveFromCartEvent(item.productId));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildQuantitySelector(context),
            const SizedBox(height: 12),
            _buildDiscountToggle(context),
            const SizedBox(height: 12),
            _buildPriceRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Cantidad',
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.read<CartBloc>().add(
                        UpdateQuantityEvent(item.productId, item.quantity - 1),
                      );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Iconsax.minus, size: 16, color: AppColors.neutral600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.neutral200),
                    right: BorderSide(color: AppColors.neutral200),
                  ),
                ),
                child: Text(
                  '${item.quantity}',
                  style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<CartBloc>().add(
                        UpdateQuantityEvent(item.productId, item.quantity + 1),
                      );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Iconsax.add, size: 16, color: AppColors.primary500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountToggle(BuildContext context) {
    final newPointsNeeded = totalPointsNeeded + (item.applyDiscount ? -500 : 500);
    final hasEnoughPoints = newPointsNeeded <= availablePoints;

    return Container(
      decoration: BoxDecoration(
        color: item.applyDiscount ? AppColors.green50 : AppColors.neutral100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.applyDiscount ? AppColors.green600 : AppColors.neutral200,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          'Aplicar 30% descuento',
          style: Typo.smallBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          item.applyDiscount
              ? 'Ahorro: \$${item.discount.toStringAsFixed(2)} (500 puntos)'
              : 'Usa 500 puntos para obtener 30% de descuento',
          style: Typo.smallBody.copyWith(
            fontSize: 11,
            color: item.applyDiscount ? AppColors.green600 : AppColors.neutral600,
          ),
        ),
        value: item.applyDiscount,
        activeColor: AppColors.green600,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onChanged: !item.applyDiscount && !hasEnoughPoints
            ? null
            : (value) {
                if (value != null) {
                  if (!item.applyDiscount && !hasEnoughPoints) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Puntos insuficientes',
                          style: Typo.mediumBody.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.red500,
                      ),
                    );
                    return;
                  }
                  context.read<CartBloc>().add(ToggleDiscountEvent(item.productId));
                }
              },
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Subtotal',
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (item.applyDiscount) ...[
          Row(
            children: [
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: Typo.smallBody.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${item.total.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.green600,
                ),
              ),
            ],
          ),
        ] else
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartState cartState;
  final int availablePoints;

  const _CartSummary({
    required this.cartState,
    required this.availablePoints,
  });

  @override
  Widget build(BuildContext context) {
    final insufficientPoints = cartState.totalPointsNeeded > availablePoints;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (cartState.totalPointsNeeded > 0)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: insufficientPoints ? AppColors.red50 : AppColors.green50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      insufficientPoints ? Iconsax.warning_2 : Iconsax.star5,
                      color: insufficientPoints ? AppColors.red600 : AppColors.green600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Puntos a usar: ${cartState.totalPointsNeeded}',
                            style: Typo.smallBody.copyWith(
                              fontWeight: FontWeight.w700,
                              color: insufficientPoints ? AppColors.red600 : AppColors.green600,
                            ),
                          ),
                          Text(
                            'Disponibles: $availablePoints',
                            style: Typo.smallBody.copyWith(
                              fontSize: 11,
                              color: insufficientPoints ? AppColors.red500 : AppColors.green500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!insufficientPoints)
                      Text(
                        'Ahorro: \$${cartState.totalDiscount.toStringAsFixed(2)}',
                        style: Typo.smallBody.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.green600,
                        ),
                      ),
                  ],
                ),
              ),
            _SummaryRow(
              label: 'Subtotal (${cartState.itemCount} items)',
              value: cartState.subtotal,
            ),
            if (cartState.totalDiscount > 0) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Descuento (${cartState.itemsWithDiscount} items)',
                value: -cartState.totalDiscount,
                color: AppColors.green600,
              ),
            ],
            Divider(color: AppColors.neutral200, height: 24),
            _SummaryRow(
              label: 'Total',
              value: cartState.total,
              bold: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: insufficientPoints
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: context.read<CartBloc>(),
                                ),
                                BlocProvider.value(
                                  value: context.read<UserBloc>(),
                                ),
                              ],
                              child: const CartCheckoutView(),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  disabledBackgroundColor: AppColors.neutral200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  insufficientPoints
                      ? 'Puntos insuficientes'
                      : 'Proceder al pago (\$${cartState.total.toStringAsFixed(2)})',
                  style: Typo.mediumBody.copyWith(
                    color: insufficientPoints ? AppColors.neutral600 : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: insufficientPoints
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: context.read<CartBloc>(),
                                ),
                                BlocProvider.value(
                                  value: context.read<UserBloc>(),
                                ),
                              ],
                              child: const CartRedeemTypeSelectionView(),
                            ),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple600,
                  side: BorderSide(
                    color: insufficientPoints ? AppColors.neutral200 : AppColors.purple600,
                    width: 2,
                  ),
                  disabledForegroundColor: AppColors.neutral600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Iconsax.ticket_discount,
                  color: insufficientPoints ? AppColors.neutral600 : AppColors.purple600,
                ),
                label: Text(
                  insufficientPoints
                      ? 'Puntos insuficientes para canje'
                      : 'Proceder al canje',
                  style: Typo.mediumBody.copyWith(
                    color: insufficientPoints ? AppColors.neutral600 : AppColors.purple600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Typo.mediumBody.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            fontSize: bold ? 16 : 14,
          ),
        ),
        Text(
          '\$${value.abs().toStringAsFixed(2)}',
          style: Typo.mediumBody.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            fontSize: bold ? 18 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
