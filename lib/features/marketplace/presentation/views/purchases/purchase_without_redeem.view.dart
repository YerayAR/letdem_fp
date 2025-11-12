import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/users/user_bloc.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import '../../../models/product.model.dart';
import '../../../models/store.model.dart';
import '../../../data/marketplace_repository.dart';

class PurchaseWithoutRedeemView extends StatefulWidget {
  final Product product;
  final Store store;
  final int quantity;

  const PurchaseWithoutRedeemView({
    super.key,
    required this.product,
    required this.store,
    required this.quantity,
  });

  @override
  State<PurchaseWithoutRedeemView> createState() => _PurchaseWithoutRedeemViewState();
}

class _PurchaseWithoutRedeemViewState extends State<PurchaseWithoutRedeemView> {
  bool _isProcessing = false;
  bool _isPurchaseComplete = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final total = widget.product.finalPrice * widget.quantity;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isPurchaseComplete
                      ? _buildSuccessScreen(total)
                      : _buildPurchaseForm(total),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!_isPurchaseComplete)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Iconsax.arrow_left, color: AppColors.neutral600),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isPurchaseComplete ? '¡Compra exitosa!' : 'Compra sin canje',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseForm(double total) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 24),
          _buildProductCard(),
          const SizedBox(height: 16),
          _buildPriceBreakdown(total),
          const SizedBox(height: 24),
          _buildPaymentSection(),
          const SizedBox(height: 24),
          _buildConfirmButton(total),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary500, AppColors.primary600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.shopping_cart,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compra normal',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sin uso de puntos',
                  style: Typo.smallBody.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.wallet_2,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.box,
              color: AppColors.primary500,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.store.name,
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${widget.quantity}',
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desglose de precio',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio unitario',
                style: Typo.mediumBody.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cantidad',
                style: Typo.mediumBody.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              Text(
                'x${widget.quantity}',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(color: AppColors.neutral200, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total a pagar',
                style: Typo.largeBody.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Typo.largeBody.copyWith(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de pago',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary200, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.card,
                  color: AppColors.primary500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tarjeta predeterminada',
                    style: Typo.mediumBody.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.primary500,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(double total) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPurchase(total),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Confirmar compra • \$${total.toStringAsFixed(2)}',
                style: Typo.mediumBody.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessScreen(double total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.tick_circle5,
                color: AppColors.green600,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Compra exitosa!',
              style: Typo.title.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tu compra ha sido\nprocesada correctamente',
              style: Typo.mediumBody.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total pagado',
                    style: Typo.mediumBody.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Typo.largeBody.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Volver al inicio (pop todas las pantallas)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Volver al inicio',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPurchase(double total) async {
    setState(() => _isProcessing = true);

    try {
      // Obtener token de autenticación
      final token = await SecureStorageHelper().read('access_token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No estás autenticado');
      }

      // Llamar al backend para iniciar la compra
      final response = await MarketplaceRepository().purchaseWithoutRedeem(
        productId: widget.product.id,
        quantity: widget.quantity,
        authToken: token,
      );

      // Si requiere pago con Stripe
      if (response['requires_payment'] == true) {
        final clientSecret = response['client_secret'];
        final paymentBreakdown = response['payment_breakdown'];
        
        // Mostrar información de pago
        final fromWallet = paymentBreakdown['from_wallet'];
        final fromStripe = paymentBreakdown['from_stripe'];
        
        if (fromWallet > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Usando €${fromWallet.toStringAsFixed(2)} de tu wallet. Procesando pago de €${fromStripe.toStringAsFixed(2)}...',
                style: Typo.smallBody.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.primary500,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        // Procesar pago con Stripe
        final paymentIntent = await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
        );
        
        if (paymentIntent.status == PaymentIntentsStatus.RequiresCapture ||
            paymentIntent.status == PaymentIntentsStatus.Succeeded) {
          // Pago exitoso, confirmar compra en backend
          await MarketplaceRepository().purchaseWithoutRedeem(
            productId: widget.product.id,
            quantity: widget.quantity,
            authToken: token,
            paymentIntentId: paymentIntent.id,
          );
          
          setState(() {
            _isProcessing = false;
            _isPurchaseComplete = true;
          });
        } else {
          throw Exception('El pago no se completó');
        }
      } else {
        // Compra completada directamente (todo de wallet)
        setState(() {
          _isProcessing = false;
          _isPurchaseComplete = true;
        });
      }
    } on StripeException catch (e) {
      setState(() => _isProcessing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error en el pago: ${e.error.localizedMessage ?? e.error.message}',
            style: Typo.mediumBody.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.red500,
        ),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al procesar la compra: ${e.toString().replaceAll('Exception: ', '')}',
            style: Typo.mediumBody.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.red500,
        ),
      );
    }
  }
}
