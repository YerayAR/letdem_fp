import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/common/widgets/appbar.dart';
import 'package:letdem/common/widgets/body.dart';
import 'package:letdem/common/widgets/button.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/marketplace_data.dart';
import 'package:letdem/features/marketplace/presentation/pages/redeems/pending_vouchers.page.dart';
import 'package:letdem/features/marketplace/presentation/pages/cart/cart.page.dart';
import 'package:letdem/features/marketplace/presentation/widgets/common/cart_icon_button.widget.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import '../../widgets/common/cart_icon_button.widget.dart';

class VirtualCardGeneratorView extends StatefulWidget {
  final int availablePoints;

  const VirtualCardGeneratorView({super.key, required this.availablePoints});

  @override
  State<VirtualCardGeneratorView> createState() =>
      _VirtualCardGeneratorViewState();
}

class _VirtualCardGeneratorViewState extends State<VirtualCardGeneratorView> {
  late final MarketplaceRepositoryImpl _repository;
  bool _isGenerating = false;
  String? _errorMessage;
  late int _selectedPoints;

  int get _maxSelectablePoints => (widget.availablePoints ~/ 500) * 500;
  bool get _hasEnoughPoints => _maxSelectablePoints >= 500;

  @override
  void initState() {
    super.initState();
    _repository = MarketplaceRepositoryImpl();
    _selectedPoints =
        _hasEnoughPoints ? math.min(500, _maxSelectablePoints) : 0;
  }

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
            suffix: MarketplaceCartIconButton(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartView()),
              );
            }),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
                Dimens.space(2),
                _buildPointsCard(),
                Dimens.space(3),
                _buildAmountSelector(),
                Dimens.space(3),
                _buildInfoCard(),
                Dimens.space(3),
                PrimaryButton(
                  text:
                      _hasEnoughPoints
                          ? 'Generar $_selectedPoints pts'
                          : 'Sin puntos suficientes',
                  isDisabled:
                      !_hasEnoughPoints ||
                      _selectedPoints == 0 ||
                      _isGenerating,
                  isLoading: _isGenerating,
                  onTap: _handleGenerate,
                ),
                if (_errorMessage != null) ...[
                  Dimens.space(1),
                  Text(
                    _errorMessage!,
                    style: Typo.smallBody.copyWith(
                      color: AppColors.red600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Convierte tus puntos en una tarjeta digital',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        Dimens.space(0.5),
        Text(
          'Podrás descargarla y compartirla con quien quieras.',
          style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildPointsCard() {
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
                  '${widget.availablePoints} pts',
                  style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSelector() {
    if (!_hasEnoughPoints) {
      return _buildInsufficientPointsCard();
    }

    final totalSteps = _maxSelectablePoints ~/ 500;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona los puntos para tu tarjeta',
            style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
          ),
          Dimens.space(1.5),
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                enabled: _selectedPoints > 500,
                onTap: () => _stepSelection(-1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$_selectedPoints pts',
                      style: Typo.largeBody.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Dimens.space(0.3),
                    Text(
                      'Se descontarán de tus puntos disponibles',
                      style: Typo.smallBody.copyWith(
                        color: AppColors.neutral600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                enabled: _selectedPoints < _maxSelectablePoints,
                onTap: () => _stepSelection(1),
              ),
            ],
          ),
          if (totalSteps > 1) ...[
            Dimens.space(2),
            Slider(
              value: _selectedPoints.toDouble(),
              min: 500,
              max: _maxSelectablePoints.toDouble(),
              divisions: totalSteps - 1,
              activeColor: AppColors.primary500,
              label: '$_selectedPoints pts',
              onChanged: (value) => _updateSelectedPoints(value.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '500 pts',
                  style: Typo.smallBody.copyWith(color: AppColors.neutral500),
                ),
                Text(
                  '${_maxSelectablePoints} pts',
                  style: Typo.smallBody.copyWith(color: AppColors.neutral500),
                ),
              ],
            ),
          ],
          Dimens.space(1),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary500, size: 20),
                Dimens.space(1),
                Expanded(
                  child: Text(
                    'Las tarjetas se generan en incrementos de 500 puntos. Te quedarán ${widget.availablePoints - _selectedPoints} pts.',
                    style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsufficientPointsCard() {
    final missingPoints = (500 - widget.availablePoints).clamp(0, 500);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock, color: AppColors.neutral500),
              Dimens.space(1),
              Text(
                'Necesitas al menos 500 puntos',
                style: Typo.mediumBody.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Dimens.space(1),
          Text(
            'Te faltan $missingPoints pts para poder generar tu primera tarjeta.',
            style: Typo.smallBody.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary50 : AppColors.neutral200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.primary500 : AppColors.neutral500,
          ),
        ),
      ),
    );
  }

  void _stepSelection(int direction) {
    final nextValue = _selectedPoints + (direction * 500);
    _updateSelectedPoints(nextValue);
  }

  void _updateSelectedPoints(int value) {
    if (!_hasEnoughPoints) return;
    final sanitized = (value ~/ 500) * 500;
    final clamped = sanitized.clamp(500, _maxSelectablePoints);
    setState(() {
      _selectedPoints = clamped;
      _errorMessage = null;
    });
  }

  Future<void> _handleGenerate() async {
    if (!_hasEnoughPoints || _selectedPoints < 500 || _isGenerating) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final token = await SecureStorageHelper().read('access_token');
      if (token == null || token.isEmpty) {
        throw Exception('No estás autenticado');
      }

      final voucher = await _repository.createVirtualCard(
        points: _selectedPoints,
        redeemType: 'ONLINE',
        authToken: token,
      );

      if (!mounted) return;

      context.read<UserBloc>().add(const FetchUserInfoEvent(isSilent: true));
      _showSuccessDialog(voucher);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      setState(() => _errorMessage = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Typo.mediumBody.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.red500,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showSuccessDialog(Voucher voucher) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Tarjeta generada',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta estilo "bancaria" con el código
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4C1D95),
                    Color(0xFF6D28D9),
                    Color(0xFFEC4899),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tarjeta virtual LetDem',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'ONLINE',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Dimens.space(2),
                  Text(
                    voucher.code,
                    style: Typo.largeBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      fontSize: 24,
                    ),
                  ),
                  Dimens.space(1),
                  Text(
                    '${voucher.pointsUsed} puntos · ${voucher.discountPercentage.toInt()}% de descuento',
                    style: Typo.smallBody.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Dimens.space(1.5),
            Text(
              'Puedes ver esta tarjeta en la sección de pendientes.',
              style: Typo.smallBody.copyWith(color: AppColors.neutral600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Listo',
              style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PendingVouchersView(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ver tarjetas'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
          _bullet('Elige cuántos puntos quieres transferir en bloques de 500.'),
          _bullet(
            'Generamos una tarjeta virtual con un código único listo para usar.',
          ),
          _bullet(
            'Encuéntrala siempre en tus tarjetas pendientes dentro del marketplace.',
          ),
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
          Text(
            '• ',
            style: Typo.mediumBody.copyWith(color: AppColors.primary500),
          ),
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
