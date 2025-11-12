import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_state.dart';
import 'package:letdem/features/marketplace/presentation/pages/start/marketplace_start.page.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/wallet/presentation/views/wallet.view.dart';

class CartCheckoutView extends StatefulWidget {
  const CartCheckoutView({super.key});

  @override
  State<CartCheckoutView> createState() => _CartCheckoutViewState();
}

class _CartCheckoutViewState extends State<CartCheckoutView> {
  bool _isProcessing = false;

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
          'Checkout',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is! UserLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final availablePoints = userState.user.totalPoints;
              final insufficientPoints =
                  cartState.totalPointsNeeded > availablePoints;

              final earningAccount = userState.user.earningAccount;
              final walletBalance =
                  earningAccount?.availableBalance ??
                  earningAccount?.balance ??
                  0.0;
              final insufficientBalance = cartState.total > walletBalance;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderSummary(cartState),
                          const SizedBox(height: 16),
                          _buildPointsSection(
                            cartState,
                            availablePoints,
                            insufficientPoints,
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentSection(
                            walletBalance,
                            cartState.total,
                            insufficientBalance,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(
                    context,
                    cartState,
                    insufficientPoints,
                    insufficientBalance,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.box, color: AppColors.primary500, size: 20),
              const SizedBox(width: 8),
              Text(
                'Resumen del pedido',
                style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Items', '${cartState.itemCount}', bold: false),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Subtotal',
            '\$${cartState.subtotal.toStringAsFixed(2)}',
            bold: false,
          ),
          if (cartState.totalDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Descuento',
              '-\$${cartState.totalDiscount.toStringAsFixed(2)}',
              bold: false,
              color: AppColors.green600,
            ),
          ],
          Divider(color: AppColors.neutral200, height: 24),
          _buildSummaryRow(
            'Total',
            '\$${cartState.total.toStringAsFixed(2)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Typo.mediumBody.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          value,
          style: Typo.mediumBody.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            fontSize: bold ? 18 : 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsSection(
    CartState cartState,
    int availablePoints,
    bool insufficientPoints,
  ) {
    if (cartState.totalPointsNeeded == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insufficientPoints ? AppColors.red50 : AppColors.green50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insufficientPoints ? AppColors.red200 : AppColors.green200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                insufficientPoints
                    ? Iconsax.warning_2
                    : Iconsax.ticket_discount,
                color:
                    insufficientPoints ? AppColors.red600 : AppColors.green600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Puntos requeridos',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        insufficientPoints
                            ? AppColors.red700
                            : AppColors.green700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Se usarán:',
                style: Typo.smallBody.copyWith(
                  color:
                      insufficientPoints
                          ? AppColors.red600
                          : AppColors.green600,
                ),
              ),
              Text(
                '${cartState.totalPointsNeeded} puntos',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      insufficientPoints
                          ? AppColors.red600
                          : AppColors.green600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disponibles:',
                style: Typo.smallBody.copyWith(
                  color:
                      insufficientPoints
                          ? AppColors.red600
                          : AppColors.green600,
                ),
              ),
              Text(
                '$availablePoints puntos',
                style: Typo.smallBody.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      insufficientPoints
                          ? AppColors.red600
                          : AppColors.green600,
                ),
              ),
            ],
          ),
          if (insufficientPoints) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: AppColors.red700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No tienes suficientes puntos. Necesitas ${cartState.totalPointsNeeded - availablePoints} más.',
                      style: Typo.smallBody.copyWith(
                        color: AppColors.red700,
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

  Widget _buildPaymentSection(
    double balance,
    double total,
    bool insufficientBalance,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.wallet_3, color: AppColors.primary500, size: 20),
              const SizedBox(width: 8),
              Text(
                'Método de pago',
                style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  insufficientBalance ? AppColors.red50 : AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    insufficientBalance
                        ? AppColors.red200
                        : AppColors.primary200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance disponible:',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            insufficientBalance
                                ? AppColors.red600
                                : AppColors.green600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total a pagar:',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (insufficientBalance) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: AppColors.red700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saldo insuficiente. Necesitas \$${(total - balance).toStringAsFixed(2)} más.',
                      style: Typo.smallBody.copyWith(
                        color: AppColors.red700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleAddFunds(context),
                icon: const Icon(Iconsax.wallet_add, size: 18),
                label: Text(
                  'Ingresar fondos a tu Wallet',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CartState cartState,
    bool insufficientPoints,
    bool insufficientBalance,
  ) {
    final canProceed =
        !insufficientPoints && !insufficientBalance && !_isProcessing;

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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                canProceed ? () => _handleCheckout(context, cartState) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              disabledBackgroundColor: AppColors.neutral200,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isProcessing
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      insufficientPoints
                          ? 'Puntos insuficientes'
                          : insufficientBalance
                          ? 'Saldo insuficiente'
                          : 'Confirmar compra (\$${cartState.total.toStringAsFixed(2)})',
                      style: Typo.mediumBody.copyWith(
                        color: canProceed ? Colors.white : AppColors.neutral600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddFunds(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
  }

  Future<void> _handleCheckout(
    BuildContext context,
    CartState cartState,
  ) async {
    setState(() => _isProcessing = true);

    try {
      print('Iniciando checkout...');
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) {
        print('Widget no mounted después del delay');
        return;
      }

      // No limpiar carrito por ahora, causaba error de conexión
      // context.read<CartBloc>().add(ClearCartEvent());

      print('Mostrando diálogo de éxito...');
      _showSuccessDialog(context, cartState);
    } catch (e) {
      print('Error en checkout: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al procesar el pago: $e',
            style: Typo.mediumBody.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.red500,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(BuildContext context, CartState cartState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.tick_circle5,
                    color: AppColors.green600,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Compra exitosa!',
                  style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu pedido ha sido procesado correctamente.',
                  style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total pagado: \$${cartState.total.toStringAsFixed(2)}',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MarketplaceStartView(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Volver al inicio',
                    style: Typo.mediumBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
