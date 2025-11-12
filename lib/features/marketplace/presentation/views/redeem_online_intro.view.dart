import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'redeem_online_scanner.view.dart';

class RedeemOnlineIntroView extends StatelessWidget {
  const RedeemOnlineIntroView({super.key});

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
                      _buildMainIcon(),
                      Dimens.space(4),
                      Text(
                        'Canje Online',
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                        ),
                      ),
                      Dimens.space(2),
                      Text(
                        'Escanea el código QR del producto en la tienda online para aplicar tu descuento del 30%',
                        style: Typo.mediumBody.copyWith(
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                      ),
                      Dimens.space(5),
                      _buildInstructions(),
                      Dimens.space(5),
                      _buildInfoCard(),
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

  Widget _buildMainIcon() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.purple600.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Iconsax.scan_barcode,
          size: 60,
          color: AppColors.purple600,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo funciona',
          style: Typo.mediumBody.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        Dimens.space(2),
        _buildInstructionStep(
          number: '1',
          title: 'Busca el producto',
          description: 'Navega en la tienda online y encuentra el producto que deseas',
        ),
        Dimens.space(2),
        _buildInstructionStep(
          number: '2',
          title: 'Escanea el código QR',
          description: 'En la página del producto encontrarás un código QR, escanéalo con tu cámara',
        ),
        Dimens.space(2),
        _buildInstructionStep(
          number: '3',
          title: 'Confirma el canje',
          description: 'Verifica la información y confirma para aplicar tu descuento del 30%',
        ),
        Dimens.space(2),
        _buildInstructionStep(
          number: '4',
          title: 'Usa tu descuento',
          description: 'Tendrás 2 días para completar tu compra con el descuento aplicado',
        ),
      ],
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.purple600,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: Typo.mediumBody.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
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
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Typo.smallBody.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple600.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            color: AppColors.purple600,
            size: 24,
          ),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Importante',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este canje consume 500 puntos y tiene una validez de 2 días. Si no completas la compra, los puntos se devolverán automáticamente.',
                  style: Typo.smallBody.copyWith(
                  color: AppColors.neutral600,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RedeemOnlineScannerView(),
                    ),
                  );
                },
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
                    Icon(Iconsax.scan, size: 20),
                    Dimens.space(1),
                    Text(
                      'Escanear código QR',
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
