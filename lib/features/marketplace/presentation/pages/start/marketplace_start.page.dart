import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/assets.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/core/extensions/locale.dart';
import 'package:letdem/core/extensions/user.dart';
import 'package:letdem/features/marketplace/presentation/bloc/store_catalog_bloc.dart';
import 'package:letdem/features/marketplace/presentation/views/catalog/store_catalog.view.dart';
import 'package:letdem/features/marketplace/presentation/views/purchases/order_history.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/pending_vouchers.view.dart';
import 'package:letdem/features/marketplace/presentation/views/redeems/virtual_card_generator.view.dart';
import 'package:letdem/features/marketplace/presentation/views/cart/cart.view.dart';
import 'package:letdem/features/marketplace/presentation/widgets/marketplace_menu_item.widget.dart';
import 'package:letdem/features/payout_methods/presentation/views/payout.view.dart';
import 'package:letdem/features/users/presentation/views/orders/orders.view.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/features/wallet/presentation/views/all_transactions.view.dart';
import 'package:letdem/features/wallet/presentation/views/send_money.view.dart';
import 'package:letdem/features/withdrawals/presentation/views/withdraw.view.dart';
import 'package:letdem/features/withdrawals/presentation/views/withdrawals.view.dart';
import 'package:letdem/infrastructure/services/res/navigator.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';

class MarketplaceStartView extends StatelessWidget {
  const MarketplaceStartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: StyledBody(
        children: [
          _buildMarketplaceHeader(context),
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  // Permite arrastrar hacia abajo para refrescar saldo, puntos, etc.
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(
                            const FetchUserInfoEvent(isSilent: true),
                          );
                      // Pequeño delay para dar tiempo al bloc a actualizar.
                      await Future.delayed(const Duration(milliseconds: 300));
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildVirtualCardCallout(context, state.user.totalPoints),
                        Dimens.space(2),
                        _buildEarningsCard(context, state.user.earningAccount),
                        Dimens.space(1.5),
                        _buildWalletActionsRow(context),
                        Dimens.space(3),
                        _buildMarketplaceGrid(context, state.user.totalPoints),
                      ],
                    ),
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

  Widget _buildMarketplaceHeader(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Inicio',
              style: Typo.heading4,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          // Solo botón de carrito a la derecha
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartView()),
              );
            },
            child: CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.neutral50,
              child: Icon(
                Iconsax.shopping_cart,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, EarningAccount? earningAccount) {
    final balance = earningAccount?.balance ?? 0.0;
    final formattedBalance = '${balance.toStringAsFixed(2)} €';

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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.walletBalance,
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Dimens.space(1),
            Text(
              formattedBalance,
              style: Typo.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Dimens.space(2),
            PrimaryButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<StoreCatalogBloc>(),
                      child: const StoreCatalogView(),
                    ),
                  ),
                );
              },
              text: context.l10n.buy,
              color: Colors.white,
              textColor: const Color(0xFF7B00CC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletActionsRow(BuildContext context) {
    return Row(
      children: [
        _WalletActionButton(
          icon: AppAssets.location,
          label: context.l10n.orders,
          onTap: () => NavigatorHelper.to(const OrdersListView()),
        ),
        const SizedBox(width: 12),
        _WalletActionButton(
          icon: AppAssets.card,
          label: context.l10n.withdrawals,
          onTap: () => NavigatorHelper.to(const WithdrawListView()),
        ),
        const SizedBox(width: 12),
        _WalletActionButton(
          icon: AppAssets.bank,
          label: context.l10n.payouts,
          onTap: () => NavigatorHelper.to(const PayoutMethodsScreen()),
        ),
        const SizedBox(width: 12),
        _WalletActionButton(
          icon: '',
          label: context.l10n.sendMoney,
          onTap: () => NavigatorHelper.to(const SendMoneyView()),
          useSvg: false,
          iconData: Iconsax.send_2,
        ),
      ],
    );
  }

  Widget _buildMarketplaceGrid(BuildContext context, int points) {
    final menuItems = [
      _MarketplaceItem(
        icon: IconlyBold.document,
        title: context.l10n.purchaseHistory,
        subtitle: 'Consulta lo que ya canjeaste',
        color: AppColors.green600,
        onTap: () => NavigatorHelper.to(const OrderHistoryView()),
      ),
      _MarketplaceItem(
        icon: Iconsax.ticket,
        title: context.l10n.pendingCards,
        subtitle: 'Tarjetas listas para usar',
        color: AppColors.secondary500,
        onTap: () => NavigatorHelper.to(const PendingVouchersView()),
      ),
      _MarketplaceItem(
        icon: IconlyBold.wallet,
        title: context.l10n.generateCard,
        subtitle: 'Convierte puntos en tarjeta',
        color: AppColors.primary500,
        onTap: () => NavigatorHelper.to(
          VirtualCardGeneratorView(availablePoints: points),
        ),
      ),
      _MarketplaceItem(
        icon: Iconsax.receipt_2,
        title: context.l10n.transactionsHistory,
        subtitle: 'Todas tus transacciones',
        color: AppColors.red500,
        onTap: () => NavigatorHelper.to(const AllTransactionsView()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return MarketplaceMenuItem(
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          onTap: item.onTap,
          accentColor: item.color,
          index: index,
        );
      },
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

class _WalletActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool useSvg;
  final IconData? iconData;

  const _WalletActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.useSvg = true,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.neutral50,
                child: useSvg
                    ? SvgPicture.asset(icon, color: Colors.blueGrey.shade700, width: 20)
                    : Icon(iconData, color: Colors.blueGrey.shade700, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: Typo.smallBody.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketplaceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MarketplaceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
