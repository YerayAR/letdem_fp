import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../../models/cart_item.model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState()) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ToggleDiscountEvent>(_onToggleDiscount);
    on<ClearCartEvent>(_onClearCart);
  }
  
  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((item) => item.productId == event.item.productId);
    
    if (existingIndex >= 0) {
      items[existingIndex].quantity += event.item.quantity;
    } else {
      items.add(event.item);
    }
    
    emit(state.copyWith(items: items));
  }
  
  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    final items = state.items.where((item) => item.productId != event.productId).toList();
    emit(state.copyWith(items: items));
  }
  
  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.productId == event.productId);
    
    if (index >= 0) {
      if (event.quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index].quantity = event.quantity;
      }
    }
    
    emit(state.copyWith(items: items));
  }
  
  void _onToggleDiscount(ToggleDiscountEvent event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.productId == event.productId);
    
    if (index >= 0) {
      items[index].applyDiscount = !items[index].applyDiscount;
    }
    
    emit(state.copyWith(items: items));
  }
  
  void _onClearCart(ClearCartEvent event, Emitter<CartState> emit) {
    emit(CartState());
  }
}
