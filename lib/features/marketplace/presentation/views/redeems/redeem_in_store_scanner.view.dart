import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/pending_vouchers.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/virtual_card_generator.view.dart';
import 'package:letdem/features/users/user_bloc.dart';

class RedeemInStoreScannerView extends StatelessWidget {
  const RedeemInStoreScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: StyledBody(
        children: [
          StyledAppBar(
            title: 'Canjear en tienda',
            icon: IconlyLight.close_square,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildIllustration(),
                Dimens.space(2),
                Text(
                  'Ahora usamos tarjetas virtuales',
                  style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                ),
                Dimens.space(1),
                Text(
                  'Genera una tarjeta virtual descargable para mostrarla en el comercio y aplicar tus puntos.',
                  style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
                ),
                Dimens.space(3),
                _buildStep(
                  icon: Icons.credit_card,
                  title: '1. Genera tu tarjeta',
                  detail:
                      'Convierte 500 puntos en una tarjeta digital con vigencia limitada.',
                ),
                Dimens.space(1),
                _buildStep(
                  icon: Icons.timer,
                  title: '2. Respeta la vigencia',
                  detail:
                      'Online: 48 horas / En tienda: 5 minutos desde que se genera.',
                ),
                Dimens.space(1),
                _buildStep(
                  icon: Icons.store,
                  title: '3. Muéstrala en la tienda',
                  detail:
                      'El equipo de caja valida la tarjeta y completa el canje.',
                ),
                Dimens.space(3),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final points =
                        state is UserLoaded ? state.user.totalPoints : 0;
                    return PrimaryButton(
                      text: 'Generar tarjeta',
                      icon: IconlyBold.ticket,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => VirtualCardGeneratorView(
                                  availablePoints: points,
                                ),
                          ),
                        );
                      },
                      color: AppColors.primary500,
                    );
                  },
                ),
                Dimens.space(1),
                PrimaryButton(
                  text: 'Ver mis tarjetas pendientes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PendingVouchersView(),
                      ),
                    );
                  },
                  outline: true,
                  color: AppColors.primary500,
                  textColor: AppColors.primary500,
                  borderColor: AppColors.primary500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.credit_card, size: 64, color: AppColors.primary300),
          Dimens.space(1),
          Text(
            'Tu tarjeta virtual siempre lista',
            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
          ),
          Dimens.space(0.5),
          Text(
            'Descarga la tarjeta y compártela desde tu teléfono.',
            style: Typo.smallBody.copyWith(color: AppColors.neutral600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary500),
          ),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
                ),
                Dimens.space(0.5),
                Text(
                  detail,
                  style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


