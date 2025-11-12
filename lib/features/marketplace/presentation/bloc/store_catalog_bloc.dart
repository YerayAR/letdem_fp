import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/store.model.dart';
import '../../repository/marketplace_repository.dart';

part 'store_catalog_event.dart';
part 'store_catalog_state.dart';

class StoreCatalogBloc extends Bloc<StoreCatalogEvent, StoreCatalogState> {
  final MarketplaceRepository repository;
  
  StoreCatalogBloc({MarketplaceRepository? repository})
      : repository = repository ?? MarketplaceRepository(),
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
      // Convertir el enum a string para enviarlo al backend
      final categoryName = event.category.name;
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
