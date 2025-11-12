import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';
import 'package:letdem/features/marketplace/presentation/bloc/store_catalog_bloc.dart';
import 'package:letdem/features/marketplace/presentation/views/catalog/store_catalog.view.dart';
import 'package:letdem/features/marketplace/presentation/views/purchases/order_history.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/pending_vouchers.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/redeem_in_store_scanner.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/virtual_card_generator.view.dart';

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
                      _buildVirtualCardCallout(context, state.user.totalPoints),
                      Dimens.space(2),
                      _buildMonetaryBalanceCard(
                        context,
                        state.user.earningAccount,
                      ),
                      Dimens.space(3),
                      _buildActionButtons(context, state.user.totalPoints),
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

  Widget _buildMonetaryBalanceCard(
    BuildContext context,
    EarningAccount? earningAccount,
  ) {
    final walletBalance =
        earningAccount?.availableBalance ?? earningAccount?.balance ?? 0.0;
    String currencyCode = 'EUR';
    if (earningAccount != null && earningAccount.currency.isNotEmpty) {
      currencyCode = earningAccount.currency.toUpperCase();
    }
    final formatter = NumberFormat.simpleCurrency(name: currencyCode);
    final formattedBalance = formatter.format(walletBalance);
    final subtitle =
        earningAccount == null
            ? 'Activa tu wallet para usar tu saldo en el marketplace.'
            : 'Saldo disponible para tus compras en Letdem.';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B00CC), Color(0xFF450077)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B00CC).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo de tu wallet',
              style: Typo.largeBody.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Dimens.space(1),
            Text(
              subtitle,
              style: Typo.smallBody.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            Dimens.space(2),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.wallet_3, color: Colors.white),
                  ),
                  Dimens.space(2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance disponible',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        formattedBalance,
                        style: Typo.largeBody.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Dimens.space(2),
            PrimaryButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<StoreCatalogBloc>(),
                          child: const StoreCatalogView(),
                        ),
                  ),
                );
              },
              text: 'Comprar',
              color: Colors.white,
              textColor: const Color(0xFF7B00CC),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons(BuildContext context, int points) {
    return Column(
      children: [
        _buildWideActionButton(
          context,
          icon: IconlyBold.document,
          label: 'Historial de compras',
          subtitle: 'Consulta lo que ya canjeaste',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryView()),
            );
          },
        ),
        Dimens.space(1.5),
        _buildWideActionButton(
          context,
          icon: Iconsax.ticket,
          label: 'Mis tarjetas pendientes',
          subtitle: 'Revisa las tarjetas listas para usar',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingVouchersView()),
            );
          },
        ),
        Dimens.space(1.5),
        _buildWideActionButton(
          context,
          icon: Iconsax.scan_barcode,
          label: 'Canjear en tienda',
          subtitle: 'Muestra tu tarjeta virtual en caja',
          accentColor: AppColors.primary500,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RedeemInStoreScannerView(),
              ),
            );
          },
        ),
        Dimens.space(1.5),
        _buildWideActionButton(
          context,
          icon: IconlyBold.wallet,
          label: 'Generar tarjeta virtual',
          subtitle: 'Convierte tus puntos en una tarjeta descargable',
          accentColor: const Color(0xFF7B00CC),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VirtualCardGeneratorView(
                  availablePoints: points,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWideActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final iconColor = accentColor ?? AppColors.neutral600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              Dimens.space(2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Dimens.space(0.2),
                    Text(
                      subtitle,
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildVirtualCardCallout(BuildContext context, int points) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B00CC), Color(0xFF450077)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B00CC).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarjeta virtual Letdem',
              style: Typo.largeBody.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Dimens.space(1),
            Text(
              'Transfiere tus puntos a una tarjeta digital descargable para compartirla o presentarla en tienda.',
              style: Typo.smallBody.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            Dimens.space(2),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 32),
                  Dimens.space(2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Puntos disponibles',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '$points pts',
                        style: Typo.mediumBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Dimens.space(2),
            PrimaryButton(
              onTap: () => _openVirtualCard(context, points),
              text: 'Canjear puntos en tarjeta',
              color: Colors.white,
              textColor: const Color(0xFF7B00CC),
            ),
          ],
        ),
      ),
    );
  }

  void _openVirtualCard(BuildContext context, int points) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VirtualCardGeneratorView(availablePoints: points),
      ),
    );
  }
}
