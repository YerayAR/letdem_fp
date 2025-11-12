import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/dimens.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/users/user_bloc.dart';
import '../../../models/product.model.dart';
import '../../../models/store.model.dart';
import '../redeems/redeem_type_selection.view.dart';
import '../purchases/purchase_redeem_question.view.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;
  final Store store;

  const ProductDetailView({
    super.key,
    required this.product,
    required this.store,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int quantity = 1;
  bool usePoints = false;
  final int requiredPointsFor30Percent = 500;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final userPoints = userState is UserLoaded ? userState.user.totalPoints : 0;
        final baseTotal = widget.product.finalPrice * quantity;
        final pointsDiscount = (usePoints && userPoints >= requiredPointsFor30Percent ? baseTotal * 0.3 : 0).toDouble();
        final total = baseTotal - pointsDiscount;

        return Scaffold(
          backgroundColor: const Color(0xffF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProductImage(),
                        _buildStoreInfo(),
                        _buildProductInfo(),
                        _buildQuantitySelector(),
                        _buildPriceBreakdown(total, baseTotal, pointsDiscount, userPoints),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context, total, userPoints),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Iconsax.arrow_left, color: AppColors.neutral600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Detalle del producto',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 280,
              width: double.infinity,
              color: AppColors.primary50,
              child: Center(
                child: Icon(
                  _getProductIcon(widget.product.name),
                  color: AppColors.primary500,
                  size: 80,
                ),
              ),
            ),
          ),
          if (widget.product.discount > 0)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.red500,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '-${widget.product.discount.toStringAsFixed(0)}%',
                  style: Typo.largeBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            widget.store.category.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store.name,
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.store.category.displayName,
                  style: Typo.smallBody.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.arrow_right,
            color: AppColors.neutral400,
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Typo.largeBody.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Iconsax.star5,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reseñas)',
                          style: Typo.smallBody.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.product.stock} disponibles',
                  style: Typo.smallBody.copyWith(
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.product.discount > 0) ...[
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral400,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                style: Typo.largeBody.copyWith(
                  color: AppColors.primary500,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cantidad',
            style: Typo.mediumBody.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: quantity > 1
                      ? () {
                          setState(() => quantity--);
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(
                      Iconsax.minus,
                      size: 18,
                      color: quantity > 1
                          ? AppColors.neutral600
                          : AppColors.neutral300,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.neutral200),
                      right: BorderSide(color: AppColors.neutral200),
                    ),
                  ),
                  child: Text(
                    '$quantity',
                    style: Typo.mediumBody.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: quantity < widget.product.stock
                      ? () {
                          setState(() => quantity++);
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(
                      Iconsax.add,
                      size: 18,
                      color: quantity < widget.product.stock
                          ? AppColors.primary500
                          : AppColors.neutral300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(double total, double baseTotal, double pointsDiscount, int userPoints) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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
                'x$quantity',
                style: Typo.mediumBody.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (usePoints && userPoints >= requiredPointsFor30Percent) ...[          const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Descuento por puntos (30%)',
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.green600,
                  ),
                ),
                Text(
                  '-\$${pointsDiscount.toStringAsFixed(2)}',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.green600,
                  ),
                ),
              ],
            ),
          ],
          Divider(
            color: AppColors.neutral200,
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
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


  Widget _buildBottomBar(BuildContext context, double total, int userPoints) {
    final canRedeem = userPoints >= requiredPointsFor30Percent;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botones de compra normal
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.neutral200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: Typo.mediumBody.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PurchaseRedeemQuestionView(
                            product: widget.product,
                            store: widget.store,
                            quantity: quantity,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirmar compra',
                      style: Typo.mediumBody.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmPurchase(BuildContext context, double total, int userPoints) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirmar compra',
                style: Typo.largeBody.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product.name,
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'x$quantity',
                          style: Typo.mediumBody.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (usePoints && userPoints >= requiredPointsFor30Percent)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.green50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.verify5,
                                  size: 16,
                                  color: AppColors.green600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Descuento 30% por puntos aplicado',
                                  style: Typo.smallBody.copyWith(
                                    color: AppColors.green600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
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
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Compra confirmada: \$${total.toStringAsFixed(2)}',
                          style: Typo.mediumBody.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.green600,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirmar',
                    style: Typo.mediumBody.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.neutral200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: Typo.mediumBody.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('camisa') || name.contains('shirt')) return Iconsax.bag;
    if (name.contains('pantalón') || name.contains('pants')) return Iconsax.bag;
    if (name.contains('chaqueta') || name.contains('jacket')) return Iconsax.bag;
    if (name.contains('vestido') || name.contains('dress')) return Iconsax.bag;
    if (name.contains('bolso') || name.contains('bag')) return Iconsax.bag;
    if (name.contains('leche') || name.contains('milk')) return Iconsax.shopping_cart;
    if (name.contains('pan') || name.contains('bread')) return Iconsax.shopping_cart;
    if (name.contains('queso') || name.contains('cheese')) return Iconsax.shopping_cart;
    if (name.contains('paella')) return Iconsax.shopping_cart;
    if (name.contains('tarta')) return Iconsax.shopping_cart;
    if (name.contains('gasolina') || name.contains('fuel')) return Iconsax.car;
    if (name.contains('aceite') || name.contains('oil')) return Iconsax.car;
    if (name.contains('paracetamol') || name.contains('vitamina')) return Iconsax.heart;
    return Iconsax.box;
  }
}
