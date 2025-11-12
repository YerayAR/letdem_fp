part of 'store_catalog_bloc.dart';

abstract class StoreCatalogEvent extends Equatable {
  const StoreCatalogEvent();

  @override
  List<Object> get props => [];
}

class FetchStoresEvent extends StoreCatalogEvent {
  const FetchStoresEvent();
}

class SearchStoresEvent extends StoreCatalogEvent {
  final String query;

  const SearchStoresEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FilterStoresByCategoryEvent extends StoreCatalogEvent {
  final StoreCategory category;

  const FilterStoresByCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}
