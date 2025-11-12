import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_state.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/redeem_online_intro.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/redeem_in_store_intro.view.dart';

class CartRedeemTypeSelectionView extends StatelessWidget {
  const CartRedeemTypeSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Text(
                        'Tipo de Canje',
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      Dimens.space(3),
                      Text(
                        'Elige si quiere canjear los códigos online ya o hacer en el momento de la compra en la tienda (Recuerda que el canje tiene un límite temporal de 2 días)',
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                      ),
                      Dimens.space(4),
                      _buildCartSummary(context),
                      Dimens.space(5),
                      _buildRedeemOptions(context),
                    ],
                  ),
                ),
              ),
            ),
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
          Dimens.space(2),
          Text(
            'Seleccionar tipo de canje',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purple600.withOpacity(0.1),
                AppColors.purple200.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.purple200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.purple600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.shopping_cart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Dimens.space(2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen del carrito',
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${cartState.itemCount} producto${cartState.itemCount != 1 ? "s" : ""}',
                          style: Typo.smallBody.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Dimens.space(2),
              Divider(color: AppColors.purple200),
              Dimens.space(1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Typo.smallBody.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    '\$${cartState.total.toStringAsFixed(2)}',
                    style: Typo.mediumBody.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple600,
                    ),
                  ),
                ],
              ),
              if (cartState.totalPointsNeeded > 0) ...[
                Dimens.space(0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Puntos a usar:',
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      '${cartState.totalPointsNeeded} pts',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.green600,
                      ),
                    ),
                  ],
                ),
              ],
              if (cartState.totalDiscount > 0) ...[
                Dimens.space(0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ahorro total:',
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      '\$${cartState.totalDiscount.toStringAsFixed(2)}',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.green600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRedeemOptions(BuildContext context) {
    return Column(
      children: [
        _buildRedeemOptionCard(
          context: context,
          icon: Iconsax.shop,
          title: 'Canje en tienda',
          description:
              'Genera códigos QR para usar en el momento de pago en la tienda física',
          color: AppColors.primary500,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RedeemInStoreIntroView(),
              ),
            );
          },
        ),
        Dimens.space(2),
        _buildRedeemOptionCard(
          context: context,
          icon: Iconsax.global,
          title: 'Canje online',
          description:
              'Escanea los códigos QR de los productos en la tienda online para aplicar tus descuentos',
          color: AppColors.purple600,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RedeemOnlineIntroView(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRedeemOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neutral200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              Dimens.space(2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: AppColors.neutral400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
