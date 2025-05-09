import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'payout_method_event.dart';
part 'payout_method_state.dart';

class PayoutMethodBloc extends Bloc<PayoutMethodEvent, PayoutMethodState> {
  PayoutMethodBloc() : super(PayoutMethodInitial()) {
    on<PayoutMethodEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
