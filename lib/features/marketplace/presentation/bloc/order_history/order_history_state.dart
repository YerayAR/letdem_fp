import 'package:equatable/equatable.dart';

import '../../../data/models/order.model.dart';

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final OrderHistoryStats stats;
  final List<Order> orders;

  const OrderHistoryLoaded({required this.stats, required this.orders});

  @override
  List<Object?> get props => [stats, orders];
}

class OrderHistoryError extends OrderHistoryState {
  final String message;

  const OrderHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
