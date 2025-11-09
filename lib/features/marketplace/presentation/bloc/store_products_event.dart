part of 'store_products_bloc.dart';

abstract class StoreProductsEvent extends Equatable {
  const StoreProductsEvent();

  @override
  List<Object> get props => [];
}

class FetchProductsEvent extends StoreProductsEvent {
  const FetchProductsEvent();
}

class SearchProductsEvent extends StoreProductsEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object> get props => [query];
}
