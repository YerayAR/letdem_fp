import 'package:flutter/material.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';

class VirtualCardGeneratorView extends StatelessWidget {
  final int availablePoints;

  const VirtualCardGeneratorView({super.key, required this.availablePoints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: StyledBody(
        children: [
          StyledAppBar(
            title: 'Generar tarjeta virtual',
            icon: Icons.close,
            onTap: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context),
                Dimens.space(2),
                _buildPointsCard(context),
                Dimens.space(3),
                _buildInfoCard(context),
                Dimens.space(3),
                PrimaryButton(
                  text: 'Generar',
                  onTap: () {
                    // TODO: Implementar flujo real de generación de tarjeta
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Funcionalidad en desarrollo',
                          style: Typo.mediumBody.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.primary500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Convierte tus puntos en una tarjeta digital',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        Dimens.space(0.5),
        Text(
          'Podrás descargarla y presentarla en tienda o compartirla.',
          style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.credit_card, color: AppColors.primary500),
          ),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntos disponibles',
                  style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                ),
                Text(
                  '$availablePoints pts',
                  style:
                      Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cómo funciona',
            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
          ),
          Dimens.space(1),
          _bullet('Define el importe en puntos que deseas canjear.'),
          _bullet('Generamos una tarjeta virtual con un código único.'),
          _bullet('Descárgala o muéstrala en caja para canjearla.'),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: Typo.smallBody.copyWith(color: AppColors.neutral600),
            ),
          ),
        ],
      ),
    );
  }
}
