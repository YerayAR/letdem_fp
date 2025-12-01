import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/models/cart_item.model.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_state.dart';
import 'package:letdem/features/marketplace/presentation/pages/cart/cart_checkout.page.dart';
import 'package:letdem/features/users/user_bloc.dart';

class CartPointsSelectionView extends StatefulWidget {
  const CartPointsSelectionView({super.key});

  @override
  State<CartPointsSelectionView> createState() => _CartPointsSelectionViewState();
}

class _CartPointsSelectionViewState extends State<CartPointsSelectionView> {
  // Map productId -> number of units with discount applied (0 to quantity)
  final Map<String, int> _unitsWithDiscount = {};

  int _getTotalPointsUsed() {
    int total = 0;
    for (final units in _unitsWithDiscount.values) {
      total += units * 500;
    }
    return total;
  }

  int _getTotalUnitsWithDiscount() {
    int total = 0;
    for (final units in _unitsWithDiscount.values) {
      total += units;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: AppColors.neutral600),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Usar puntos',
          style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              if (userState is! UserLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final availablePoints = userState.user.totalPoints;
              final totalPointsUsed = _getTotalPointsUsed();
              final remainingPoints = availablePoints - totalPointsUsed;

              return Column(
                children: [
                  _buildHeader(availablePoints, totalPointsUsed, remainingPoints),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartState.items.length,
                      itemBuilder: (context, index) {
                        final item = cartState.items[index];
                        final unitsWithDiscount = _unitsWithDiscount[item.productId] ?? 0;

                        return _buildProductCard(
                          item: item,
                          unitsWithDiscount: unitsWithDiscount,
                          remainingPoints: remainingPoints,
                          onAdd: () {
                            if (remainingPoints >= 500 && unitsWithDiscount < item.quantity) {
                              setState(() {
                                _unitsWithDiscount[item.productId] = unitsWithDiscount + 1;
                              });
                            }
                          },
                          onRemove: () {
                            if (unitsWithDiscount > 0) {
                              setState(() {
                                final newUnits = unitsWithDiscount - 1;
                                if (newUnits == 0) {
                                  _unitsWithDiscount.remove(item.productId);
                                } else {
                                  _unitsWithDiscount[item.productId] = newUnits;
                                }
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
                  _buildBottomBar(context, cartState),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(int availablePoints, int totalPointsUsed, int remainingPoints) {
    final totalUnits = _getTotalUnitsWithDiscount();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.purple600, AppColors.purple700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Puntos disponibles',
                    style: Typo.smallBody.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    '$availablePoints pts',
                    style: Typo.largeBody.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Restante: $remainingPoints pts',
                  style: Typo.smallBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.ticket_discount, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Unidades con descuento: $totalUnits',
                      style: Typo.mediumBody.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$totalPointsUsed pts',
                  style: Typo.mediumBody.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required CartItem item,
    required int unitsWithDiscount,
    required int remainingPoints,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    final subtotal = item.price * item.quantity;
    final discountPerUnit = item.price * 0.3;
    final totalDiscount = discountPerUnit * unitsWithDiscount;
    final finalTotal = subtotal - totalDiscount;
    final pointsForItem = unitsWithDiscount * 500;
    final canAddMore = remainingPoints >= 500 && unitsWithDiscount < item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: unitsWithDiscount > 0 ? AppColors.purple50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unitsWithDiscount > 0 ? AppColors.purple600 : AppColors.neutral200,
          width: unitsWithDiscount > 0 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and price breakdown
            Text(
              item.productName,
              style: Typo.mediumBody.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            
            // Price calculation: quantity x price = subtotal
            Row(
              children: [
                Text(
                  '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  ' = ',
                  style: Typo.mediumBody.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: Typo.mediumBody.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Points selector
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: unitsWithDiscount > 0 
                    ? AppColors.purple200.withOpacity(0.5) 
                    : AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aplicar puntos (500 pts = 30% OFF)',
                          style: Typo.smallBody.copyWith(
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Máximo: ${item.quantity} unidades',
                          style: Typo.smallBody.copyWith(
                            color: AppColors.neutral500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stepper controls
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: Row(
                      children: [
                        _buildStepperButton(
                          icon: Icons.remove,
                          onTap: unitsWithDiscount > 0 ? onRemove : null,
                        ),
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: Text(
                            '$unitsWithDiscount',
                            style: Typo.mediumBody.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.purple600,
                            ),
                          ),
                        ),
                        _buildStepperButton(
                          icon: Icons.add,
                          onTap: canAddMore ? onAdd : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Show discount info when points are applied
            if (unitsWithDiscount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.green200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Puntos usados:',
                          style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                        ),
                        Text(
                          '$pointsForItem pts',
                          style: Typo.smallBody.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ahorro:',
                          style: Typo.smallBody.copyWith(color: AppColors.neutral600),
                        ),
                        Text(
                          '-\$${totalDiscount.toStringAsFixed(2)}',
                          style: Typo.smallBody.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total producto:',
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\$${finalTotal.toStringAsFixed(2)}',
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? AppColors.purple600 : AppColors.neutral300,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CartState cartState) {
    // Calculate totals
    double subtotal = 0;
    double totalDiscount = 0;
    
    for (final item in cartState.items) {
      subtotal += item.price * item.quantity;
      final unitsWithDiscount = _unitsWithDiscount[item.productId] ?? 0;
      totalDiscount += item.price * 0.3 * unitsWithDiscount;
    }
    
    final total = subtotal - totalDiscount;
    final totalPointsUsed = _getTotalPointsUsed();
    final hasDiscount = totalPointsUsed > 0;

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
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: Typo.mediumBody.copyWith(color: AppColors.neutral600),
                      ),
                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: Typo.mediumBody,
                      ),
                    ],
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.ticket_discount, 
                                size: 16, color: AppColors.green600),
                            const SizedBox(width: 4),
                            Text(
                              'Ahorro ($totalPointsUsed pts)',
                              style: Typo.mediumBody.copyWith(
                                color: AppColors.green600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '-\$${totalDiscount.toStringAsFixed(2)}',
                          style: Typo.mediumBody.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 20),
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.purple600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Pass discount info to checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                            value: context.read<CartBloc>(),
                          ),
                          BlocProvider.value(
                            value: context.read<UserBloc>(),
                          ),
                        ],
                        child: const CartCheckoutView(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  hasDiscount
                      ? 'Continuar con $totalPointsUsed pts de descuento'
                      : 'Continuar sin descuentos',
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
}
