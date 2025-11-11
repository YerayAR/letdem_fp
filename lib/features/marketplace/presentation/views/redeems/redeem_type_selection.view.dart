import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/models/product.model.dart';
import 'package:letdem/features/marketplace/models/store.model.dart';
import 'redeem_online_intro.view.dart';
import 'redeem_in_store_intro.view.dart';

class RedeemTypeSelectionView extends StatelessWidget {
  final Product product;
  final Store store;

  const RedeemTypeSelectionView({
    super.key,
    required this.product,
    required this.store,
  });

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
                        'Elige si quiere canjear el código online ya o hacer en el momento de la compra en la tienda (Recuerda que el canje tiene un límite temporal de 2 días)',
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                      ),
                      Dimens.space(4),
                      _buildProductInfo(),
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
              Iconsax.close_square,
              color: AppColors.neutral600,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary500.withOpacity(0.1),
            AppColors.primary200.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.box,
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
                      product.name,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      store.name,
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
          Divider(color: AppColors.primary200),
          Dimens.space(1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio:',
                style: Typo.smallBody.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                '\$${product.finalPrice.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          Dimens.space(0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Descuento con 500 pts:',
                style: Typo.smallBody.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                '30% OFF',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.green600,
                ),
              ),
            ],
          ),
        ],
      ),
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
              'Genera un código QR para usar en el momento de pago en la tienda física',
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
              'Escanea el código QR del producto en la tienda online para aplicar tu descuento',
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

  void _showComingSoonDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Iconsax.info_circle,
              color: AppColors.primary500,
            ),
            Dimens.space(1),
            Text(
              'Próximamente',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'La funcionalidad de "$type" estará disponible próximamente.',
          style: Typo.mediumBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: Typo.mediumBody.copyWith(
                color: AppColors.primary500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
