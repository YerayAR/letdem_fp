import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/presentation/bloc/store_catalog_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_bloc.dart';
import 'package:letdem/features/marketplace/presentation/bloc/cart/cart_state.dart';
import 'package:letdem/features/marketplace/models/store.model.dart';
import 'package:letdem/features/marketplace/presentation/widgets/store_card.widget.dart';
import 'package:letdem/features/marketplace/presentation/widgets/category_filter.widget.dart';
import 'package:letdem/features/marketplace/presentation/views/cart/cart.view.dart';

class StoreCatalogView extends StatefulWidget {
  const StoreCatalogView({super.key});

  @override
  State<StoreCatalogView> createState() => _StoreCatalogViewState();
}

class _StoreCatalogViewState extends State<StoreCatalogView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<StoreCatalogBloc>().add(const FetchStoresEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildCategoryFilter(context),
            Expanded(
              child: _buildStoresList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          if (cartState.isEmpty) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CartBloc>(),
                    child: const CartView(),
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary500,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Iconsax.shopping_cart, color: Colors.white),
                if (cartState.itemCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.red500,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cartState.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(
              'Ver carrito',
              style: Typo.mediumBody.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
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
              'Catálogo de Tiendas',
              style: Typo.largeBody.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CartBloc>(),
                        child: const CartView(),
                      ),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Iconsax.shopping_cart,
                      color: AppColors.neutral600,
                      size: 24,
                    ),
                    if (cartState.itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.red500,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartState.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          if (query.isEmpty) {
            context.read<StoreCatalogBloc>().add(const FetchStoresEvent());
          } else {
            context.read<StoreCatalogBloc>().add(SearchStoresEvent(query));
          }
        },
        decoration: InputDecoration(
          hintText: 'Buscar tiendas...',
          hintStyle: Typo.mediumBody.copyWith(
            color: AppColors.neutral400,
          ),
          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.neutral400),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    context.read<StoreCatalogBloc>().add(const FetchStoresEvent());
                  },
                  child: Icon(Iconsax.close_circle, color: AppColors.neutral400),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neutral200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary500),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: Typo.mediumBody,
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: StoreCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryFilterChip(
              category: category,
              onTap: () {
                _searchController.clear();
                context.read<StoreCatalogBloc>().add(
                  FilterStoresByCategoryEvent(category),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStoresList(BuildContext context) {
    return BlocBuilder<StoreCatalogBloc, StoreCatalogState>(
      builder: (context, state) {
        if (state is StoreCatalogLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is StoreCatalogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.close_circle,
                  size: 48,
                  color: AppColors.red500,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Typo.mediumBody,
                ),
              ],
            ),
          );
        }

        if (state is StoreCatalogEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.search_status,
                  size: 48,
                  color: AppColors.neutral400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontraron tiendas para "${state.query}"',
                  textAlign: TextAlign.center,
                  style: Typo.mediumBody,
                ),
              ],
            ),
          );
        }

        if (state is StoreCatalogLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.stores.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StoreCard(store: state.stores[index]),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
