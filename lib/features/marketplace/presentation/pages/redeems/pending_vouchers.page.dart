import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/marketplace_data.dart';
import 'package:letdem/features/marketplace/presentation/bloc/pending_vouchers/pending_vouchers_cubit.dart';
import 'package:letdem/features/marketplace/presentation/bloc/pending_vouchers/pending_vouchers_state.dart';

class PendingVouchersView extends StatelessWidget {
  const PendingVouchersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              PendingVouchersCubit(MarketplaceRepositoryImpl())
                ..loadPendingVouchers(),
      child: const _PendingVouchersContent(),
    );
  }
}

class _PendingVouchersContent extends StatefulWidget {
  const _PendingVouchersContent();

  @override
  State<_PendingVouchersContent> createState() =>
      _PendingVouchersContentState();
}

class _PendingVouchersContentState extends State<_PendingVouchersContent> {
  String _selectedFilter = 'all'; // all, online, in_store

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Tarjetas y productos pendientes',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.neutral900),
      ),
      body: BlocConsumer<PendingVouchersCubit, PendingVouchersState>(
        listener: (context, state) {
          if (state is PendingVouchersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red600,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PendingVouchersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingVouchersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 64, color: AppColors.red600),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar vouchers',
                    style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            context
                                .read<PendingVouchersCubit>()
                                .refreshVouchers(),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PendingVouchersLoaded ||
              state is PendingVouchersCancelling) {
            final vouchers =
                state is PendingVouchersLoaded
                    ? state.vouchers
                    : (state as PendingVouchersCancelling).vouchers;

            if (vouchers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.ticket, size: 64, color: AppColors.neutral300),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes tarjetas ni productos pendientes',
                      style: Typo.largeBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus canjes pendientes aparecerán aquí',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final filteredVouchers = _filterVouchers(vouchers);

            return RefreshIndicator(
              onRefresh:
                  () => context.read<PendingVouchersCubit>().refreshVouchers(),
              child: Column(
                children: [
                  _buildFilterBar(),
                  Expanded(
                    child:
                        filteredVouchers.isEmpty
                            ? _buildEmptyFilterState()
                            : ListView(
                              padding: EdgeInsets.all(Dimens.defaultMargin),
                              children: [
                                _buildInfoCard(),
                                Dimens.space(2),
                                ...filteredVouchers.map(
                                  (voucher) => _buildVoucherCard(
                                    context,
                                    voucher,
                                    state is PendingVouchersCancelling,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<Voucher> _filterVouchers(List<Voucher> vouchers) {
    switch (_selectedFilter) {
      case 'online':
        return vouchers.where((v) => v.redeemType == 'ONLINE').toList();
      case 'in_store':
        return vouchers.where((v) => v.redeemType == 'IN_STORE').toList();
      default:
        return vouchers;
    }
  }

  Widget _buildFilterBar() {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todos', 'all'),
            Dimens.space(1),
            _buildFilterChip('Online', 'online'),
            Dimens.space(1),
            _buildFilterChip('En tienda', 'in_store'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple600 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Typo.smallBody.copyWith(
            color: isSelected ? Colors.white : AppColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.purple600.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Iconsax.info_circle, color: AppColors.purple600, size: 24),
          Dimens.space(2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tarjetas y productos pendientes',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estos son tus canjes activos. Tienes tiempo limitado para usarlos antes de que expiren.',
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

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.filter_remove, size: 64, color: AppColors.neutral300),
          const SizedBox(height: 16),
          Text(
            'No hay vouchers en esta categoría',
            style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro filtro',
            style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard(
    BuildContext context,
    Voucher voucher,
    bool isCancelling,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');
    final now = DateTime.now();
    final hoursRemaining = voucher.expiresAt.difference(now).inHours;
    final isExpiringSoon = hoursRemaining < 24;

    final bool isCardOnly =
        voucher.productId == null || voucher.productName.trim().isEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (isCardOnly) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardVoucherDetailPage(voucher: voucher),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductVoucherDetailPage(voucher: voucher),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpiringSoon
                ? AppColors.secondary600.withOpacity(0.3)
                : AppColors.neutral200,
            width: isExpiringSoon ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con tipo de canje
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: voucher.redeemType == 'ONLINE'
                    ? AppColors.purple50
                    : AppColors.primary50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    voucher.redeemType == 'ONLINE'
                        ? Iconsax.global
                        : Iconsax.shop,
                    size: 18,
                    color: voucher.redeemType == 'ONLINE'
                        ? AppColors.purple600
                        : AppColors.primary600,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.redeemTypeDisplay,
                        style: Typo.mediumBody.copyWith(
                          fontWeight: FontWeight.w700,
                          color: voucher.redeemType == 'ONLINE'
                              ? AppColors.purple600
                              : AppColors.primary600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCardOnly ? 'Tarjeta virtual' : 'Canje de producto',
                        style: Typo.smallBody.copyWith(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      voucher.statusDisplay,
                      style: Typo.smallBody.copyWith(
                        color: AppColors.secondary600,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Producto y tienda
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.box,
                          color: AppColors.primary500,
                          size: 24,
                        ),
                      ),
                      Dimens.space(2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.productName,
                              style: Typo.mediumBody.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.storeName,
                              style: Typo.smallBody.copyWith(
                                color: AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Dimens.space(2),
                  const Divider(),
                  Dimens.space(2),

                  // Descuento y precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descuento',
                            style: Typo.smallBody.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${voucher.discountPercentage.toInt()}% OFF',
                            style: Typo.mediumBody.copyWith(
                              color: AppColors.green600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Precio final',
                            style: Typo.smallBody.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${voucher.finalPrice.toStringAsFixed(2)}',
                            style: Typo.mediumBody.copyWith(
                              color: AppColors.purple600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Dimens.space(2),

                  // Puntos usados
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.star_1,
                          size: 16,
                          color: AppColors.secondary500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${voucher.pointsUsed} puntos usados',
                          style: Typo.smallBody.copyWith(
                            color: AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Dimens.space(2),

                  // Tiempo de expiración
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isExpiringSoon
                          ? AppColors.secondary50
                          : AppColors.primary50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpiringSoon
                            ? AppColors.secondary600.withOpacity(0.3)
                            : AppColors.primary600.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isExpiringSoon ? Iconsax.warning_2 : Iconsax.clock,
                          size: 18,
                          color: isExpiringSoon
                              ? AppColors.secondary600
                              : AppColors.primary600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isExpiringSoon
                                    ? '¡Expira pronto!'
                                    : 'Expira el',
                                style: Typo.smallBody.copyWith(
                                  color: isExpiringSoon
                                      ? AppColors.secondary600
                                      : AppColors.primary600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormat.format(voucher.expiresAt),
                                style: Typo.smallBody.copyWith(
                                  color: AppColors.neutral700,
                                ),
                              ),
                              if (hoursRemaining > 0)
                                Text(
                                  'Quedan ${hoursRemaining}h',
                                  style: Typo.smallBody.copyWith(
                                    color: isExpiringSoon
                                        ? AppColors.secondary600
                                        : AppColors.neutral600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (voucher.canCancel) ...[
                    Dimens.space(2),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isCancelling
                            ? null
                            : () => _showCancelDialog(context, voucher),
                        icon: Icon(
                          Iconsax.close_circle,
                          size: 18,
                          color: isCancelling
                              ? AppColors.neutral400
                              : AppColors.red600,
                        ),
                        label: Text(
                          isCancelling ? 'Cancelando...' : 'Cancelar canje',
                          style: Typo.mediumBody.copyWith(
                            color: isCancelling
                                ? AppColors.neutral400
                                : AppColors.red600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isCancelling
                                ? AppColors.neutral300
                                : AppColors.red600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Voucher voucher) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Cancelar canje?',
              style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se cancelará el canje de:',
                  style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
                ),
                Dimens.space(2),
                Text(
                  voucher.productName,
                  style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
                ),
                Dimens.space(2),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.star_1, size: 16, color: AppColors.green600),
                      const SizedBox(width: 8),
                      Text(
                        'Se devolverán ${voucher.pointsUsed} puntos',
                        style: Typo.smallBody.copyWith(
                          color: AppColors.green700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'No cancelar',
                  style: Typo.mediumBody.copyWith(color: AppColors.neutral500),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<PendingVouchersCubit>().cancelVoucher(
                    voucher.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sí, cancelar',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

class CardVoucherDetailPage extends StatelessWidget {
  final Voucher voucher;

  const CardVoucherDetailPage({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarjeta'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple600, AppColors.primary500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple600.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarjeta virtual Letdem',
                    style: Typo.mediumBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Dimens.space(2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        voucher.code,
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          letterSpacing: 2,
                          color: AppColors.purple600,
                        ),
                      ),
                    ),
                  ),
                  Dimens.space(2),
                  Row(
                    children: [
                      Icon(Iconsax.star_1, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${voucher.pointsUsed} puntos usados',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Dimens.space(3),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Tipo de canje', voucher.redeemTypeDisplay),
                  Dimens.space(1),
                  if (voucher.storeName.isNotEmpty)
                    _detailRow('Tienda asociada', voucher.storeName),
                  Dimens.space(1),
                  _detailRow('Descuento', '${voucher.discountPercentage.toInt()}%'),
                  Dimens.space(1),
                  _detailRow('Expira el', dateFormat.format(voucher.expiresAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Typo.smallBody.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ProductVoucherDetailPage extends StatelessWidget {
  final Voucher voucher;

  const ProductVoucherDetailPage({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');
    final discount = voucher.discountPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de canje'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      backgroundColor: AppColors.scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.box,
                      color: AppColors.primary500,
                    ),
                  ),
                  Dimens.space(2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.productName,
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          voucher.storeName,
                          style: Typo.smallBody.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Dimens.space(2),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Código de canje',
                    style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                  ),
                  Dimens.space(1),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        voucher.code,
                        style: Typo.largeBody.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  Dimens.space(2),
                  _detailRow('Tipo de canje', voucher.redeemTypeDisplay),
                  Dimens.space(1),
                  _detailRow('Precio original',
                      '\$${voucher.productPrice.toStringAsFixed(2)}'),
                  Dimens.space(1),
                  _detailRow('Descuento', '${discount.toInt()}%'),
                  Dimens.space(1),
                  _detailRow('Precio final',
                      '\$${voucher.finalPrice.toStringAsFixed(2)}'),
                  Dimens.space(1),
                  _detailRow('Expira el', dateFormat.format(voucher.expiresAt)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Typo.smallBody.copyWith(color: AppColors.neutral600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
