import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/models/product.model.dart';
import 'package:letdem/features/marketplace/models/store.model.dart';
import 'redeem_online_success.view.dart';
import 'dart:async';

class RedeemOnlineProcessingView extends StatefulWidget {
  final Product product;
  final Store store;

  const RedeemOnlineProcessingView({
    super.key,
    required this.product,
    required this.store,
  });

  @override
  State<RedeemOnlineProcessingView> createState() =>
      _RedeemOnlineProcessingViewState();
}

class _RedeemOnlineProcessingViewState
    extends State<RedeemOnlineProcessingView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentStep = 0;
  final List<String> _steps = [
    'Validando producto...',
    'Verificando puntos...',
    'Descontando 500 puntos...',
    'Aplicando descuento...',
    '¡Listo!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _simulateProcessing();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _simulateProcessing() async {
    // TODO: Reemplazar con llamada real al backend
    // POST /v1/marketplace/vouchers/redeem-online/
    
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      // Simular datos del voucher
      final voucherCode = 'LETDEM-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final expiresAt = DateTime.now().add(const Duration(days: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RedeemOnlineSuccessView(
            product: widget.product,
            store: widget.store,
            voucherCode: voucherCode,
            expiresAt: expiresAt,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedIcon(),
                Dimens.space(5),
                Text(
                  'Procesando canje',
                  style: Typo.largeBody.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                Dimens.space(2),
                Text(
                  'Esto solo tomará unos segundos',
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Dimens.space(5),
                _buildProgressIndicator(),
                Dimens.space(4),
                _buildStepsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.purple600,
                  AppColors.primary500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple600.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Iconsax.ticket_discount,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / _steps.length;
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.purple600,
                      AppColors.primary500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple600.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Dimens.space(1),
        Text(
          '${(_currentStep + 1)}/${_steps.length}',
          style: Typo.smallBody.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(
          _steps.length,
          (index) => _buildStepItem(index),
        ),
      ),
    );
  }

  Widget _buildStepItem(int index) {
    final bool isCompleted = index < _currentStep;
    final bool isCurrent = index == _currentStep;
    final bool isPending = index > _currentStep;

    return Padding(
      padding: EdgeInsets.only(bottom: index < _steps.length - 1 ? 16 : 0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.green600
                  : isCurrent
                      ? AppColors.purple600
                      : AppColors.neutral300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : isCurrent
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : null,
            ),
          ),
          Dimens.space(2),
          Expanded(
            child: Text(
              _steps[index],
              style: Typo.mediumBody.copyWith(
                color: isCompleted || isCurrent
                    ? AppColors.neutral800
                    : AppColors.neutral400,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
