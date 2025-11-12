import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/users/user_bloc.dart';
import '../bloc/store_catalog_bloc.dart';
import 'catalog/store_catalog.view.dart';

class MarketplaceStartView extends StatelessWidget {
  const MarketplaceStartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: StyledBody(
        children: [
          StyledAppBar(
            title: 'Inicio',
            icon: IconlyLight.close_square,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPointsCard(context, state.user.totalPoints),
                      Dimens.space(2),
                      _buildMonetaryBalanceCard(context),
                      Dimens.space(3),
                      _buildActionButtons(context),
                      Dimens.space(2),
                      _buildBackButton(context),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D00FF), Color(0xFF7B00CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Balance de Puntos',
            style: Typo.mediumBody.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Dimens.space(1),
          Text(
            '$points',
            style: Typo.largeBody.copyWith(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
          Dimens.space(2),
          PrimaryButton(
            onTap: () {
              // TODO: Implementar canjear puntos
            },
            text: 'Canjear',
            color: Colors.white,
            textColor: const Color(0xFF9D00FF),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetaryBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D00FF), Color(0xFF7B00CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Balance monetario',
            style: Typo.mediumBody.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Dimens.space(1),
          Text(
            '78€',
            style: Typo.largeBody.copyWith(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
          Dimens.space(2),
          PrimaryButton(
            onTap: () {
              // TODO: Implementar comprar
            },
            text: 'Comprar',
            color: Colors.white,
            textColor: const Color(0xFF9D00FF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            icon: IconlyBold.buy,
            label: 'Catálogo',
            onTap: () {
              print('🔥🔥🔥 CATALOG BUTTON TAPPED 🔥🔥🔥');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => StoreCatalogBloc(),
                    child: const StoreCatalogView(),
                  ),
                ),
              );
            },
          ),
        ),
        Dimens.space(2),
        Expanded(
          child: _buildActionButton(
            context,
            icon: IconlyBold.document,
            label: 'Historial',
            onTap: () {
              // TODO: Implementar historial
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: AppColors.neutral600,
                ),
                Dimens.space(1),
                Text(
                  label,
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(
                  IconlyBold.time_circle,
                  size: 32,
                  color: AppColors.neutral600,
                ),
                Dimens.space(1),
                Text(
                  'Atrás',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
