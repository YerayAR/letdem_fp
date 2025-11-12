import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/accounts/presentation/bloc/user/user_bloc.dart';

import '../../../users/user_bloc.dart';
import '../../models/product.model.dart';
import '../../models/store.model.dart';
import 'redeem_online_processing.view.dart';

class RedeemOnlineConfirmView extends StatelessWidget {
  final Product product;
  final Store store;
  final String scannedCode;

  const RedeemOnlineConfirmView({
    super.key,
    required this.product,
    required this.store,
    required this.scannedCode,
  });

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final userPoints = userState is UserLoaded ? userState.user.totalPoints : 0;
    final canRedeem = userPoints >= 500;

    return Scaffold(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSuccessIcon(),
                      Dimens.space(3),
                      Text(
                        'Confirmar Canje',
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      Dimens.space(1),
                      Text(
                        'Revisa los detalles antes de confirmar',
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      Dimens.space(4),
                      _buildProductCard(),
                      Dimens.space(3),
                      _buildStoreCard(),
                      Dimens.space(3),
                      _buildDiscountInfo(),
                      Dimens.space(3),
                      _buildPointsInfo(userPoints, canRedeem),
                      Dimens.space(3),
                      _buildExpirationInfo(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomBar(context, canRedeem),
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
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Iconsax.arrow_left,
              color: AppColors.neutral600,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.green600.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Iconsax.tick_circle, size: 40, color: AppColors.green600),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Producto',
                style: Typo.smallBody.copyWith(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Dimens.space(2),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Iconsax.box, color: AppColors.primary500, size: 28),
              ),
              Dimens.space(2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.finalPrice.toStringAsFixed(2)}',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              store.category.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  store.category.displayName,
                  style: Typo.smallBody.copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo() {
    final originalPrice = product.finalPrice;
    final discount = originalPrice * 0.30;
    final finalPrice = originalPrice - discount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple600.withOpacity(0.1),
            AppColors.purple600.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple600.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio original:',
                style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
              ),
              Text(
                '\$${originalPrice.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          Dimens.space(1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Descuento (30%):',
                style: Typo.mediumBody.copyWith(
                  color: AppColors.green600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(
                  color: AppColors.green600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Dimens.space(1),
          const Divider(),
          Dimens.space(1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio final:',
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

  Widget _buildPointsInfo(int userPoints, bool canRedeem) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            canRedeem
                ? AppColors.green600.withOpacity(0.1)
                : AppColors.red600.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              canRedeem
                  ? AppColors.green600.withOpacity(0.3)
                  : AppColors.red600.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            canRedeem ? Iconsax.wallet_check5 : Iconsax.wallet_remove5,
            color: canRedeem ? AppColors.green600 : AppColors.red600,
            size: 24,
          ),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canRedeem ? 'Puntos suficientes' : 'Puntos insuficientes',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: canRedeem ? AppColors.green600 : AppColors.red600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tienes $userPoints pts • Se usarán 500 pts',
                  style: Typo.smallBody.copyWith(color: AppColors.neutral700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orange600.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.orange600.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Iconsax.clock, color: AppColors.orange600, size: 24),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validez del descuento',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tendrás 2 días (48 horas) para usar este descuento. Si no lo usas, tus puntos serán devueltos automáticamente.',
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool canRedeem) {
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
                onPressed:
                    canRedeem
                        ? () {
                          // Navegar a vista de procesamiento
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => RedeemOnlineProcessingView(
                                    product: product,
                                    store: store,
                                  ),
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.neutral300,
                ),
                child: Text(
                  canRedeem ? 'Confirmar canje' : 'Puntos insuficientes',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Dimens.space(2),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
