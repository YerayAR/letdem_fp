import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/models/product.model.dart';
import 'package:letdem/features/marketplace/data/models/store.model.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/pages/catalog/product_detail.page.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Store? store;

  const ProductCard({super.key, required this.product, this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          store != null
              ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<CartBloc>(),
                          child: ProductDetailView(
                            product: product,
                            store: store!,
                          ),
                        ),
                  ),
                );
              }
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.primary50,
                    child: Center(
                      child: Icon(
                        _getProductIcon(product.name),
                        color: AppColors.primary500,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red500,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '-${product.discount.toStringAsFixed(0)}%',
                        style: Typo.smallBody.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Typo.mediumBody.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Iconsax.star5, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating.toStringAsFixed(1)}',
                          style: Typo.smallBody.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.discount > 0)
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: Typo.smallBody.copyWith(
                                  fontSize: 9,
                                  color: AppColors.neutral400,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '\$${product.finalPrice.toStringAsFixed(2)}',
                              style: Typo.mediumBody.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (product.stock > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Iconsax.add,
                              size: 14,
                              color: AppColors.primary500,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.red50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Agotado',
                              style: Typo.smallBody.copyWith(
                                fontSize: 8,
                                color: AppColors.red500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('camisa') || name.contains('shirt')) return Iconsax.bag;
    if (name.contains('pantalón') || name.contains('pants')) return Iconsax.bag;
    if (name.contains('chaqueta') || name.contains('jacket'))
      return Iconsax.bag;
    if (name.contains('vestido') || name.contains('dress')) return Iconsax.bag;
    if (name.contains('bolso') || name.contains('bag')) return Iconsax.bag;
    if (name.contains('leche') || name.contains('milk'))
      return Iconsax.shopping_cart;
    if (name.contains('pan') || name.contains('bread'))
      return Iconsax.shopping_cart;
    if (name.contains('queso') || name.contains('cheese'))
      return Iconsax.shopping_cart;
    if (name.contains('paella')) return Iconsax.shopping_cart;
    if (name.contains('tarta')) return Iconsax.shopping_cart;
    if (name.contains('gasolina') || name.contains('fuel')) return Iconsax.car;
    if (name.contains('aceite') || name.contains('oil')) return Iconsax.car;
    if (name.contains('paracetamol') || name.contains('vitamina'))
      return Iconsax.heart;
    return Iconsax.box;
  }
}
