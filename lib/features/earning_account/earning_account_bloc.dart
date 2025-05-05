import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/earning_account/repository/earning.repository.dart';

import 'earning_account_event.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository repository;

  EarningsBloc({required this.repository}) : super(EarningsInitial()) {
    on<SubmitEarningsAccount>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitAccount(event.dto);
        emit(EarningsSuccess());
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsAddress>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitAddress(event.dto);
        emit(EarningsSuccess());
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsDocument>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitDocument(event.dto);
        emit(EarningsSuccess());
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsBankAccount>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitBankAccount(event.dto);
        emit(EarningsSuccess());
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });
  }
}
