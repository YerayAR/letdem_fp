import '../../../models/cart_item.model.dart';

class CartState {
  final List<CartItem> items;
  
  CartState({this.items = const []});
  
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  
  double get totalDiscount => items.fold(0.0, (sum, item) => sum + item.discount);
  
  double get total => subtotal - totalDiscount;
  
  int get totalPointsNeeded => items.fold(0, (sum, item) => sum + item.pointsNeeded);
  
  int get itemsWithDiscount => items.where((item) => item.applyDiscount).length;
  
  bool get isEmpty => items.isEmpty;
  
  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}
