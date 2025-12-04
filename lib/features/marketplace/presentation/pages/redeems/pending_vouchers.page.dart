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
import 'package:letdem/features/marketplace/presentation/widgets/common/cart_icon_button.widget.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import '../../widgets/common/cart_icon_button.widget.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import '../cart/cart.page.dart';

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

  final _repository = MarketplaceRepositoryImpl();
  bool _isLoadingOrders = false;
  String? _ordersError;
  List<Order> _ordersWithCanje = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersWithCanje();
  }

  Future<void> _loadOrdersWithCanje() async {
    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });

    try {
      final token = await SecureStorageHelper().read('access_token');
      if (token == null || token.isEmpty) {
        setState(() {
          _ordersWithCanje = [];
          _ordersError = 'No estás autenticado';
        });
        return;
      }

      final history = await _repository.fetchOrderHistory(authToken: token);
      final orders = history.orders.where((o) => o.usedPoints).toList();

      if (!mounted) return;
      setState(() {
        _ordersWithCanje = orders;
        _ordersError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ordersWithCanje = [];
        _ordersError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Productos Pendientes',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.neutral900),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MarketplaceCartIconButton(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartView()),
              );
            }),
          ),
        ],
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
                      'No tienes productos pendientes',
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
              onRefresh: () async {
                await context.read<PendingVouchersCubit>().refreshVouchers();
                await _loadOrdersWithCanje();
              },
              child: Column(
                children: [
                  _buildFilterBar(),
                  Expanded(
                    child: _selectedFilter == 'in_store'
                        ? _buildInStoreList(filteredVouchers, state is PendingVouchersCancelling)
                        : filteredVouchers.isEmpty
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple600 : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.purple600 : AppColors.neutral300,
          ),
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

  Widget _buildInStoreList(List<Voucher> inStoreVouchers, bool isCancelling) {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if ((_ordersWithCanje.isEmpty && inStoreVouchers.isEmpty)) {
      return _buildEmptyFilterState();
    }

    return ListView(
      padding: EdgeInsets.all(Dimens.defaultMargin),
      children: [
        _buildInfoCard(),
        if (_ordersError != null) ...[
          Dimens.space(1),
          Text(
            _ordersError!,
            style: Typo.smallBody.copyWith(
              color: AppColors.red600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Dimens.space(2),
        ],
        if (_ordersWithCanje.isNotEmpty) ...[
          Text(
            'Compras con canje (en tienda)',
            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
          ),
          Dimens.space(1.5),
          ..._ordersWithCanje.map(_buildInStoreOrderCard),
          Dimens.space(2),
        ],
        if (inStoreVouchers.isNotEmpty) ...[
          Text(
            'Vouchers en tienda',
            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
          ),
          Dimens.space(1.5),
          ...inStoreVouchers.map(
            (voucher) => _buildVoucherCard(
              context,
              voucher,
              isCancelling,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInStoreOrderCard(Order order) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Compra con canje',
                  style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  dateFormat.format(order.created),
                  style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.itemsCount} producto(s)',
              style: Typo.mediumBody,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Usaste ${order.pointsUsedAmount} puntos en esta compra',
              style: Typo.smallBody.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
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
                  'Productos pendientes',
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4C1D95),
                Color(0xFF6D28D9),
                Color(0xFFEC4899),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: tipo de canje + estado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        voucher.redeemType == 'ONLINE'
                            ? Iconsax.global
                            : Iconsax.shop,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tarjeta virtual',
                          style: Typo.smallBody.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          voucher.redeemTypeDisplay,
                          style: Typo.smallBody.copyWith(
                            color: Colors.white.withOpacity(0.8),
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
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        voucher.statusDisplay,
                        style: Typo.smallBody.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                Dimens.space(2),

                // Código grande de la tarjeta
                Text(
                  voucher.code,
                  style: Typo.largeBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    fontSize: 22,
                  ),
                ),

                Dimens.space(1),

                // Producto y tienda en una sola línea compacta
                Text(
                  '${voucher.productName} · ${voucher.storeName}',
                  style: Typo.smallBody.copyWith(
                    color: Colors.white.withOpacity(0.88),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Dimens.space(1.5),

                // Fila con puntos y expiración
                Row(
                  children: [
                    Icon(
                      Iconsax.star_1,
                      size: 16,
                      color: Colors.amber.shade300,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${voucher.pointsUsed} pts',
                      style: Typo.smallBody.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      isExpiringSoon ? Iconsax.warning_2 : Iconsax.clock,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isExpiringSoon
                            ? 'Expira pronto · ${dateFormat.format(voucher.expiresAt)}'
                            : 'Expira el ${dateFormat.format(voucher.expiresAt)}',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
                            ? Colors.white70
                            : Colors.red.shade100,
                      ),
                      label: Text(
                        isCancelling ? 'Cancelando...' : 'Cancelar canje',
                        style: Typo.mediumBody.copyWith(
                          color: isCancelling
                              ? Colors.white70
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        foregroundColor: Colors.white,
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
