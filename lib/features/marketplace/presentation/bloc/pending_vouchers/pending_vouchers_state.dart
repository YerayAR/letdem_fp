import 'package:equatable/equatable.dart';
import '../../../models/voucher.model.dart';

abstract class PendingVouchersState extends Equatable {
  const PendingVouchersState();

  @override
  List<Object?> get props => [];
}

class PendingVouchersInitial extends PendingVouchersState {}

class PendingVouchersLoading extends PendingVouchersState {}

class PendingVouchersLoaded extends PendingVouchersState {
  final List<Voucher> vouchers;

  const PendingVouchersLoaded({required this.vouchers});

  @override
  List<Object?> get props => [vouchers];
}

class PendingVouchersCancelling extends PendingVouchersState {
  final List<Voucher> vouchers;

  const PendingVouchersCancelling({required this.vouchers});

  @override
  List<Object?> get props => [vouchers];
}

class PendingVouchersError extends PendingVouchersState {
  final String message;

  const PendingVouchersError(this.message);

  @override
  List<Object?> get props => [message];
}
