import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/features/marketplace/data/models/store.model.dart';

import '../../../data/repositories/marketplace_repository_impl.dart';

part 'store_catalog_event.dart';
part 'store_catalog_state.dart';

class StoreCatalogBloc extends Bloc<StoreCatalogEvent, StoreCatalogState> {
  final MarketplaceRepositoryImpl repository;

  StoreCatalogBloc({MarketplaceRepositoryImpl? repository})
    : repository = repository ?? MarketplaceRepositoryImpl(),
      super(const StoreCatalogInitial()) {
    on<FetchStoresEvent>(_onFetchStores);
    on<SearchStoresEvent>(_onSearchStores);
    on<FilterStoresByCategoryEvent>(_onFilterByCategory);
  }

  Future<void> _onFetchStores(
    FetchStoresEvent event,
    Emitter<StoreCatalogState> emit,
  ) async {
    emit(const StoreCatalogLoading());

    try {
      final stores = await repository.fetchStores();
      if (stores.isEmpty) {
        emit(const StoreCatalogEmpty(query: ''));
      } else {
        emit(StoreCatalogLoaded(stores: stores));
      }
    } catch (e) {
      emit(StoreCatalogError(message: 'Error al cargar tiendas: $e'));
    }
  }

  Future<void> _onSearchStores(
    SearchStoresEvent event,
    Emitter<StoreCatalogState> emit,
  ) async {
    try {
      final stores = await repository.fetchStores(search: event.query);

      if (stores.isEmpty) {
        emit(StoreCatalogEmpty(query: event.query));
      } else {
        emit(StoreCatalogLoaded(stores: stores));
      }
    } catch (e) {
      emit(StoreCatalogError(message: 'Error en búsqueda: $e'));
    }
  }

  Future<void> _onFilterByCategory(
    FilterStoresByCategoryEvent event,
    Emitter<StoreCatalogState> emit,
  ) async {
    try {
      // Usar el valor esperado por el backend para la categoría
      final categoryName = event.category.apiValue;
      final stores = await repository.fetchStores(category: categoryName);

      if (stores.isEmpty) {
        emit(StoreCatalogEmpty(query: event.category.displayName));
      } else {
        emit(StoreCatalogLoaded(stores: stores));
      }
    } catch (e) {
      emit(StoreCatalogError(message: 'Error al filtrar: $e'));
    }
  }
}
