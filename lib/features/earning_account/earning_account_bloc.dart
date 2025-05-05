import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'earning_account_event.dart';
part 'earning_account_state.dart';

class EarningAccountBloc extends Bloc<EarningAccountEvent, EarningAccountState> {
  EarningAccountBloc() : super(EarningAccountInitial()) {
    on<EarningAccountEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
