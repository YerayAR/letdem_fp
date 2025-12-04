import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:letdem/core/constants/colors.dart';
import 'package:letdem/core/constants/typo.dart';
import 'package:letdem/features/marketplace/data/models/store.model.dart';
import 'package:letdem/features/marketplace/presentation/bloc/store_catalog/store_catalog_bloc.dart';
import 'package:letdem/features/marketplace/presentation/widgets/common/category_filter.widget.dart';
import 'package:letdem/features/marketplace/presentation/widgets/common/store_card.widget.dart';
import 'package:letdem/features/marketplace/presentation/widgets/common/cart_icon_button.widget.dart';
import '../cart/cart.page.dart';
import '../../widgets/common/cart_icon_button.widget.dart';

class StoreCatalogView extends StatefulWidget {
  const StoreCatalogView({super.key});

  @override
  State<StoreCatalogView> createState() => _StoreCatalogViewState();
}

class _StoreCatalogViewState extends State<StoreCatalogView> {
  late TextEditingController _searchController;
  StoreCategory? _selectedCategory;

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
            Expanded(child: _buildStoresList(context)),
          ],
        ),
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
              style: Typo.largeBody.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          MarketplaceCartIconButton(onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartView()),
            );
          }),
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
          // Si el usuario escribe texto, limpiamos el filtro de categoría
          if (query.isEmpty) {
            if (_selectedCategory == null) {
              context.read<StoreCatalogBloc>().add(const FetchStoresEvent());
            } else {
              context.read<StoreCatalogBloc>().add(
                    FilterStoresByCategoryEvent(_selectedCategory!),
                  );
            }
          } else {
            setState(() {
              _selectedCategory = null;
            });
            context.read<StoreCatalogBloc>().add(SearchStoresEvent(query));
          }
        },
        decoration: InputDecoration(
          hintText: 'Buscar tiendas...',
          hintStyle: Typo.mediumBody.copyWith(color: AppColors.neutral400),
          prefixIcon: Icon(Iconsax.search_normal, color: AppColors.neutral400),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      context.read<StoreCatalogBloc>().add(
                        const FetchStoresEvent(),
                      );
                    },
                    child: Icon(
                      Iconsax.close_circle,
                      color: AppColors.neutral400,
                    ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryFilterChip(
              category: category,
              isSelected: isSelected,
              onTap: () {
                _searchController.clear();
                setState(() {
                  if (isSelected) {
                    _selectedCategory = null;
                    context
                        .read<StoreCatalogBloc>()
                        .add(const FetchStoresEvent());
                  } else {
                    _selectedCategory = category;
                    context
                        .read<StoreCatalogBloc>()
                        .add(FilterStoresByCategoryEvent(category));
                  }
                });
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
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StoreCatalogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.close_circle, size: 48, color: AppColors.red500),
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
