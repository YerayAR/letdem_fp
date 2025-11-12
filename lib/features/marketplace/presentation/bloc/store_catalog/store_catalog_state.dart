part of 'store_catalog_bloc.dart';

abstract class StoreCatalogState extends Equatable {
  const StoreCatalogState();

  @override
  List<Object?> get props => [];
}

class StoreCatalogInitial extends StoreCatalogState {
  const StoreCatalogInitial();
}

class StoreCatalogLoading extends StoreCatalogState {
  const StoreCatalogLoading();
}

class StoreCatalogLoaded extends StoreCatalogState {
  final List<Store> stores;

  const StoreCatalogLoaded({required this.stores});

  @override
  List<Object> get props => [stores];
}

class StoreCatalogEmpty extends StoreCatalogState {
  final String query;

  const StoreCatalogEmpty({required this.query});

  @override
  List<Object> get props => [query];
}

class StoreCatalogError extends StoreCatalogState {
  final String message;

  const StoreCatalogError({required this.message});

  @override
  List<Object> get props => [message];
}
