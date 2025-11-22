import '../../../data/models/cart_item.model.dart';

abstract class CartEvent {}

class AddToCartEvent extends CartEvent {
  final CartItem item;
  AddToCartEvent(this.item);
}

class RemoveFromCartEvent extends CartEvent {
  final String productId;
  RemoveFromCartEvent(this.productId);
}

class UpdateQuantityEvent extends CartEvent {
  final String productId;
  final int quantity;
  UpdateQuantityEvent(this.productId, this.quantity);
}

class ToggleDiscountEvent extends CartEvent {
  final String productId;
  ToggleDiscountEvent(this.productId);
}

class ClearCartEvent extends CartEvent {}
