import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product.model.dart';
import '../../repository/marketplace_repository.dart';

part 'store_products_event.dart';
part 'store_products_state.dart';

class StoreProductsBloc extends Bloc<StoreProductsEvent, StoreProductsState> {
  final String storeId;
  final MarketplaceRepository repository;

  StoreProductsBloc({
    required this.storeId,
    MarketplaceRepository? repository,
  })  : repository = repository ?? MarketplaceRepository(),
        super(const StoreProductsInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  final Map<String, List<Product>> _storeProducts = {
    '1': [
      Product(
        id: '1-1',
        name: 'Camisa X',
        description: 'Camisa casual de alta calidad',
        imageUrl: 'https://via.placeholder.com/200?text=Camisa+X',
        price: 29.99,
        discount: 10,
        stock: 50,
        rating: 4.5,
        reviewCount: 128,
        storeId: '1',
      ),
      Product(
        id: '1-2',
        name: 'Pantalón B',
        description: 'Pantalón cómodo para el día a día',
        imageUrl: 'https://via.placeholder.com/200?text=Pantalon+B',
        price: 49.99,
        discount: 15,
        stock: 30,
        rating: 4.3,
        reviewCount: 95,
        storeId: '1',
      ),
      Product(
        id: '1-3',
        name: 'Chaqueta Premium',
        description: 'Chaqueta de invierno premium',
        imageUrl: 'https://via.placeholder.com/200?text=Chaqueta',
        price: 89.99,
        discount: 0,
        stock: 15,
        rating: 4.8,
        reviewCount: 156,
        storeId: '1',
      ),
    ],
    '2': [
      Product(
        id: '2-1',
        name: 'Leche Fresca',
        description: 'Leche fresca de calidad premium',
        imageUrl: 'https://via.placeholder.com/200?text=Leche',
        price: 2.49,
        discount: 5,
        stock: 100,
        rating: 4.7,
        reviewCount: 203,
        storeId: '2',
      ),
      Product(
        id: '2-2',
        name: 'Pan Integral',
        description: 'Pan integral recién horneado',
        imageUrl: 'https://via.placeholder.com/200?text=Pan',
        price: 3.99,
        discount: 0,
        stock: 60,
        rating: 4.6,
        reviewCount: 142,
        storeId: '2',
      ),
      Product(
        id: '2-3',
        name: 'Queso Manchego',
        description: 'Queso manchego auténtico',
        imageUrl: 'https://via.placeholder.com/200?text=Queso',
        price: 8.99,
        discount: 10,
        stock: 25,
        rating: 4.9,
        reviewCount: 87,
        storeId: '2',
      ),
    ],
    '3': [
      Product(
        id: '3-1',
        name: 'Vestido Elegante',
        description: 'Vestido elegante para ocasiones especiales',
        imageUrl: 'https://via.placeholder.com/200?text=Vestido',
        price: 79.99,
        discount: 20,
        stock: 20,
        rating: 4.8,
        reviewCount: 156,
        storeId: '3',
      ),
      Product(
        id: '3-2',
        name: 'Bolso Designer',
        description: 'Bolso de diseñador italiano',
        imageUrl: 'https://via.placeholder.com/200?text=Bolso',
        price: 149.99,
        discount: 0,
        stock: 10,
        rating: 4.9,
        reviewCount: 203,
        storeId: '3',
      ),
    ],
    '4': [
      Product(
        id: '4-1',
        name: 'Gasolina 95',
        description: 'Combustible de alta octanaje',
        imageUrl: 'https://via.placeholder.com/200?text=Gasolina',
        price: 1.599,
        discount: 0,
        stock: 999,
        rating: 4.4,
        reviewCount: 500,
        storeId: '4',
      ),
      Product(
        id: '4-2',
        name: 'Aceite Motor',
        description: 'Aceite sintético de calidad',
        imageUrl: 'https://via.placeholder.com/200?text=Aceite',
        price: 24.99,
        discount: 5,
        stock: 80,
        rating: 4.6,
        reviewCount: 120,
        storeId: '4',
      ),
    ],
    '5': [
      Product(
        id: '5-1',
        name: 'Paracetamol 500mg',
        description: 'Analgésico y antipirético',
        imageUrl: 'https://via.placeholder.com/200?text=Paracetamol',
        price: 4.99,
        discount: 0,
        stock: 200,
        rating: 4.7,
        reviewCount: 87,
        storeId: '5',
      ),
      Product(
        id: '5-2',
        name: 'Vitamina C',
        description: 'Suplemento de vitamina C',
        imageUrl: 'https://via.placeholder.com/200?text=Vitamina',
        price: 9.99,
        discount: 10,
        stock: 150,
        rating: 4.5,
        reviewCount: 65,
        storeId: '5',
      ),
    ],
    '6': [
      Product(
        id: '6-1',
        name: 'Paella Valenciana',
        description: 'Paella tradicional valenciana',
        imageUrl: 'https://via.placeholder.com/200?text=Paella',
        price: 16.99,
        discount: 0,
        stock: 30,
        rating: 4.9,
        reviewCount: 142,
        storeId: '6',
      ),
      Product(
        id: '6-2',
        name: 'Tarta de Santiago',
        description: 'Postre tradicional gallego',
        imageUrl: 'https://via.placeholder.com/200?text=Tarta',
        price: 12.99,
        discount: 5,
        stock: 40,
        rating: 4.8,
        reviewCount: 98,
        storeId: '6',
      ),
    ],
  };

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<StoreProductsState> emit,
  ) async {
    emit(const StoreProductsLoading());
    
    try {
      final products = await repository.fetchProducts(storeId: storeId);
      
      if (products.isEmpty) {
        emit(const StoreProductsEmpty());
      } else {
        emit(StoreProductsLoaded(products: products));
      }
    } catch (e) {
      emit(StoreProductsError(message: 'Error al cargar productos: $e'));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<StoreProductsState> emit,
  ) async {
    try {
      final products = await repository.fetchProducts(
        storeId: storeId,
        search: event.query,
      );

      if (products.isEmpty) {
        emit(const StoreProductsEmpty());
      } else {
        emit(StoreProductsLoaded(products: products));
      }
    } catch (e) {
      emit(StoreProductsError(message: 'Error en búsqueda: $e'));
    }
  }
}
