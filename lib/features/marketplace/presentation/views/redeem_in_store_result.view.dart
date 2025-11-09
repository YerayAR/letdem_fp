import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';

class RedeemInStoreResultView extends StatelessWidget {
  final bool success;
  final String storeName;
  final double? amount;
  final double? discount;
  final double? finalAmount;
  final String? errorMessage;

  const RedeemInStoreResultView({
    super.key,
    required this.success,
    required this.storeName,
    this.amount,
    this.discount,
    this.finalAmount,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: success ? AppColors.green50 : AppColors.red50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Dimens.space(6),
                      _buildResultIcon(),
                      Dimens.space(3),
                      Text(
                        success ? '¡Descuento Aplicado!' : 'Error en el Canje',
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: success
                              ? AppColors.green600
                              : AppColors.red600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Dimens.space(2),
                      Text(
                        success
                            ? 'Tu descuento del 30% ha sido aplicado correctamente'
                            : errorMessage ??
                                'No se pudo aplicar el descuento. Intenta nuevamente',
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Dimens.space(5),
                      if (success) _buildSuccessDetails(),
                      if (!success) _buildErrorInfo(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
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
          Text(
            'Resultado del Canje',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Volver a la pantalla principal del marketplace
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

  Widget _buildResultIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: success
            ? AppColors.green600.withOpacity(0.1)
            : AppColors.red600.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        success ? Iconsax.tick_circle5 : Iconsax.close_circle5,
        size: 60,
        color: success ? AppColors.green600 : AppColors.red600,
      ),
    );
  }

  Widget _buildSuccessDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.shop,
                  color: AppColors.primary500,
                  size: 24,
                ),
              ),
              Dimens.space(2),
              Expanded(
                child: Text(
                  storeName,
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Dimens.space(3),
          Divider(color: AppColors.neutral200),
          Dimens.space(2),
          _buildDetailRow(
            label: 'Subtotal',
            value: '\$${amount?.toStringAsFixed(2) ?? '0.00'}',
            isTotal: false,
          ),
          Dimens.space(1.5),
          _buildDetailRow(
            label: 'Descuento (30%)',
            value: '- \$${discount?.toStringAsFixed(2) ?? '0.00'}',
            isTotal: false,
            valueColor: AppColors.green600,
          ),
          Dimens.space(2),
          Divider(color: AppColors.neutral200),
          Dimens.space(2),
          _buildDetailRow(
            label: 'Total a Pagar',
            value: '\$${finalAmount?.toStringAsFixed(2) ?? '0.00'}',
            isTotal: true,
          ),
          Dimens.space(3),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.green600.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.tick_circle,
                  color: AppColors.green600,
                  size: 20,
                ),
                Dimens.space(1),
                Expanded(
                  child: Text(
                    'Se descontaron 500 puntos de tu cuenta',
                    style: Typo.smallBody.copyWith(
                      color: AppColors.green600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required bool isTotal,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Typo.mediumBody.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.neutral900 : AppColors.neutral600,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          value,
          style: Typo.mediumBody.copyWith(
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ??
                (isTotal ? AppColors.primary500 : AppColors.neutral900),
            fontSize: isTotal ? 24 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.information,
            size: 48,
            color: AppColors.red600.withOpacity(0.5),
          ),
          Dimens.space(2),
          Text(
            'Posibles causas:',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Dimens.space(2),
          _buildErrorReasonItem('Código QR inválido o expirado'),
          _buildErrorReasonItem('No tienes suficientes puntos (mínimo 500)'),
          _buildErrorReasonItem('Error de conexión con el servidor'),
          _buildErrorReasonItem('La tienda no acepta este tipo de canje'),
          Dimens.space(3),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: AppColors.neutral600,
                  size: 20,
                ),
                Dimens.space(1),
                Expanded(
                  child: Text(
                    'Contacta al personal de la tienda si el problema persiste',
                    style: Typo.smallBody.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorReasonItem(String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.red600,
              shape: BoxShape.circle,
            ),
          ),
          Dimens.space(1),
          Expanded(
            child: Text(
              reason,
              style: Typo.smallBody.copyWith(
                color: AppColors.neutral700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
                onPressed: () {
                  // Volver al inicio del marketplace
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: success
                      ? AppColors.primary500
                      : AppColors.neutral700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  success ? 'Volver al Inicio' : 'Intentar Nuevamente',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!success) ...[
              Dimens.space(1.5),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Cancelar',
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
