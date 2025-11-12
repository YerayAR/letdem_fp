import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/users/user_bloc.dart';
import '../../../models/product.model.dart';
import '../../../models/store.model.dart';
import 'purchase_with_redeem.view.dart';
import 'purchase_without_redeem.view.dart';

class PurchaseRedeemQuestionView extends StatelessWidget {
  final Product product;
  final Store store;
  final int quantity;

  const PurchaseRedeemQuestionView({
    super.key,
    required this.product,
    required this.store,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final userPoints = userState is UserLoaded ? userState.user.totalPoints : 0;
        final hasEnoughPoints = userPoints >= 500;
        final baseTotal = product.finalPrice * quantity;
        final discountAmount = baseTotal * 0.3;
        final totalWithDiscount = baseTotal - discountAmount;

        return Scaffold(
          backgroundColor: const Color(0xffF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildQuestionCard(),
                        const SizedBox(height: 24),
                        _buildProductSummary(),
                        const SizedBox(height: 24),
                        _buildPointsInfo(userPoints, hasEnoughPoints),
                        const SizedBox(height: 24),
                        _buildComparisonCard(baseTotal, discountAmount, totalWithDiscount),
                        const SizedBox(height: 24),
                        if (hasEnoughPoints) ...[
                          _buildRedeemButton(context, true),
                          const SizedBox(height: 12),
                          _buildNormalButton(context, false),
                        ] else
                          _buildInsufficientPointsCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Iconsax.arrow_left, color: AppColors.neutral600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '¿Quieres canjear puntos?',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple600, AppColors.purple700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple600.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.ticket_discount,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¿Quieres usar tus puntos?',
            style: Typo.title.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Canjea 500 puntos y obtén un 30% de descuento',
            style: Typo.mediumBody.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de compra',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ),
              Text(
                'x$quantity',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tienda',
                style: Typo.smallBody.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              Text(
                store.name,
                style: Typo.smallBody.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfo(int userPoints, bool hasEnoughPoints) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasEnoughPoints ? AppColors.green50 : AppColors.red50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasEnoughPoints ? AppColors.green200 : AppColors.red200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasEnoughPoints ? AppColors.green600 : AppColors.red500,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasEnoughPoints ? Iconsax.verify5 : Iconsax.close_circle5,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tus puntos: $userPoints',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hasEnoughPoints ? AppColors.green700 : AppColors.red700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasEnoughPoints
                      ? 'Tienes suficientes puntos para canjear'
                      : 'Necesitas 500 puntos para canjear',
                  style: Typo.smallBody.copyWith(
                    color: hasEnoughPoints ? AppColors.green600 : AppColors.red600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(double baseTotal, double discountAmount, double totalWithDiscount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparación de precios',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceOption(
                  'Sin canje',
                  baseTotal,
                  AppColors.neutral500,
                  false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceOption(
                  'Con canje (30%)',
                  totalWithDiscount,
                  AppColors.green600,
                  true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.wallet_add,
                  size: 16,
                  color: AppColors.green600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ahorras \$${discountAmount.toStringAsFixed(2)} canjeando',
                  style: Typo.smallBody.copyWith(
                    color: AppColors.green700,
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

  Widget _buildPriceOption(String label, double price, Color color, bool isRecommended) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Typo.smallBody.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: Typo.mediumBody.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isRecommended)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '¡Mejor precio!',
                style: Typo.smallBody.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRedeemButton(BuildContext context, bool hasEnoughPoints) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseWithRedeemView(
                product: product,
                store: store,
                quantity: quantity,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        icon: Icon(Iconsax.ticket_discount, color: Colors.white),
        label: Text(
          'Sí, canjear 500 puntos (30% OFF)',
          style: Typo.mediumBody.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildNormalButton(BuildContext context, bool hasEnoughPoints) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseWithoutRedeemView(
                product: product,
                store: store,
                quantity: quantity,
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.neutral300, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'No, comprar sin canje',
          style: Typo.mediumBody.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildInsufficientPointsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.red50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.red200),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.info_circle,
            color: AppColors.red500,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No tienes suficientes puntos',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.red700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Necesitas al menos 500 puntos para canjear. Puedes continuar con la compra normal.',
            style: Typo.smallBody.copyWith(
              color: AppColors.red600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PurchaseWithoutRedeemView(
                      product: product,
                      store: store,
                      quantity: quantity,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continuar sin canje',
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
