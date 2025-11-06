part of 'store_products_bloc.dart';

abstract class StoreProductsState extends Equatable {
  const StoreProductsState();

  @override
  List<Object?> get props => [];
}

class StoreProductsInitial extends StoreProductsState {
  const StoreProductsInitial();
}

class StoreProductsLoading extends StoreProductsState {
  const StoreProductsLoading();
}

class StoreProductsLoaded extends StoreProductsState {
  final List<Product> products;

  const StoreProductsLoaded({required this.products});

  @override
  List<Object> get props => [products];
}

class StoreProductsEmpty extends StoreProductsState {
  const StoreProductsEmpty();
}

class StoreProductsError extends StoreProductsState {
  final String message;

  const StoreProductsError({required this.message});

  @override
  List<Object> get props => [message];
}
