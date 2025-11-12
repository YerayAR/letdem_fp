import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/models/product.model.dart';
import 'package:letdem/features/marketplace/models/store.model.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_event.dart';
import 'package:letdem/features/marketplace/presentation/bloc/pending_vouchers/pending_vouchers_cubit.dart';
import 'dart:async';

class RedeemOnlineSuccessView extends StatefulWidget {
  final Product product;
  final Store store;
  final String voucherCode;
  final DateTime expiresAt;

  const RedeemOnlineSuccessView({
    super.key,
    required this.product,
    required this.store,
    required this.voucherCode,
    required this.expiresAt,
  });

  @override
  State<RedeemOnlineSuccessView> createState() =>
      _RedeemOnlineSuccessViewState();
}

class _RedeemOnlineSuccessViewState extends State<RedeemOnlineSuccessView> {
  late Timer _timer;
  Duration _timeRemaining = const Duration();

  @override
  void initState() {
    super.initState();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining();
    });
    
    // Eliminar el producto del carrito y recargar pendientes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Eliminar del carrito
      context.read<CartBloc>().add(RemoveFromCartEvent(widget.product.id));
      
      // Recargar vouchers pendientes para mostrar el nuevo voucher
      try {
        context.read<PendingVouchersCubit>().refreshVouchers();
      } catch (e) {
        // Si el cubit no está disponible, no hacemos nada
        print('PendingVouchersCubit no disponible: $e');
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    if (mounted) {
      setState(() {
        _timeRemaining = widget.expiresAt.difference(DateTime.now());
        if (_timeRemaining.isNegative) {
          _timeRemaining = Duration.zero;
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      return '${days}d ${remainingHours}h';
    }
    
    return '${hours}h ${minutes}m ${seconds}s';
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.voucherCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.copy_success, color: Colors.white, size: 20),
            Dimens.space(1),
            Text(
              'Código copiado al portapapeles',
              style: Typo.mediumBody.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.green600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openStoreWebsite() {
    // TODO: Abrir URL de la tienda online
    // url_launcher: launch(store.websiteUrl)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'TODO: Abrir ${widget.store.name} en el navegador',
          style: Typo.mediumBody.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSuccessAnimation(),
                        Dimens.space(4),
                        Text(
                          '¡Canje Exitoso!',
                          style: Typo.largeBody.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Dimens.space(1),
                        Text(
                          'Tu descuento está listo para usar',
                          style: Typo.mediumBody.copyWith(
                            color: AppColors.neutral600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Dimens.space(5),
                        _buildVoucherCodeCard(),
                        Dimens.space(3),
                        _buildDiscountSummary(),
                        Dimens.space(3),
                        _buildExpirationCard(),
                        Dimens.space(4),
                        _buildInstructions(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24),
          Text(
            'Canje Completado',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Regresar al inicio del marketplace
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Icon(
              Iconsax.close_square,
              color: AppColors.neutral600,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.green600,
            AppColors.green600.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.green600.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Iconsax.tick_circle5,
        size: 70,
        color: Colors.white,
      ),
    );
  }

  Widget _buildVoucherCodeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple600,
            AppColors.purple600.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple600.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tu código de descuento',
            style: Typo.smallBody.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          Dimens.space(2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.voucherCode,
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: 2,
                color: AppColors.purple600,
              ),
            ),
          ),
          Dimens.space(2),
          ElevatedButton.icon(
            onPressed: _copyCodeToClipboard,
            icon: const Icon(Iconsax.copy, size: 18),
            label: Text(
              'Copiar código',
              style: Typo.mediumBody.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.purple600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSummary() {
    final discount = widget.product.finalPrice * 0.30;
    final finalPrice = widget.product.finalPrice - discount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green600.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.green600.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.discount_shape,
                color: AppColors.green600,
                size: 24,
              ),
              Dimens.space(1),
              Text(
                'Resumen del descuento',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.green600,
                ),
              ),
            ],
          ),
          Dimens.space(2),
          _buildSummaryRow('Producto', widget.product.name),
          Dimens.space(1),
          _buildSummaryRow('Tienda', widget.store.name),
          Dimens.space(1),
          const Divider(),
          Dimens.space(1),
          _buildSummaryRow(
            'Precio original',
            '\$${widget.product.finalPrice.toStringAsFixed(2)}',
          ),
          Dimens.space(1),
          _buildSummaryRow(
            'Descuento (30%)',
            '-\$${discount.toStringAsFixed(2)}',
            valueColor: AppColors.green600,
          ),
          Dimens.space(1),
          const Divider(),
          Dimens.space(1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio final',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${finalPrice.toStringAsFixed(2)}',
                style: Typo.largeBody.copyWith(
                  color: AppColors.purple600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Typo.smallBody.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        Text(
          value,
          style: Typo.smallBody.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary600.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.clock,
                color: AppColors.secondary600,
                size: 24,
              ),
              Dimens.space(1),
              Text(
                'Tiempo restante',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary600,
                ),
              ),
            ],
          ),
          Dimens.space(2),
          Text(
            _formatDuration(_timeRemaining),
            style: Typo.largeBody.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary600,
            ),
          ),
          Dimens.space(1),
          Text(
            'Expira el ${_formatDateTime(widget.expiresAt)}',
            style: Typo.smallBody.copyWith(
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} a las ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary500.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: AppColors.primary500,
                size: 20,
              ),
              Dimens.space(1),
              Text(
                'Cómo usar tu código',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          Dimens.space(2),
          _buildInstructionItem(
            '1',
            'Visita la tienda online de ${widget.store.name}',
          ),
          Dimens.space(1),
          _buildInstructionItem(
            '2',
            'Agrega el producto a tu carrito',
          ),
          Dimens.space(1),
          _buildInstructionItem(
            '3',
            'En el checkout, ingresa el código de descuento',
          ),
          Dimens.space(1),
          _buildInstructionItem(
            '4',
            'Completa tu compra con el 30% de descuento aplicado',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary500,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: Typo.smallBody.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Dimens.space(1),
        Expanded(
          child: Text(
            text,
            style: Typo.smallBody.copyWith(
              color: AppColors.neutral700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openStoreWebsite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.global, size: 20),
                    Dimens.space(1),
                    Text(
                      'Ir a la tienda',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Dimens.space(2),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.neutral300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Volver al inicio',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
