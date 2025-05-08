import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/wallet/repository/transaction.repository.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final TransactionRepository transactionRepository;
  WalletBloc({
    required this.transactionRepository,
  }) : super(WalletInitial()) {
    on<FetchTransactionsEvent>(_onFetchTransactions);
  }

  Future<void> _onFetchTransactions(
      FetchTransactionsEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    try {
      final transactions =
          await transactionRepository.fetchTransactions(event.filters);
      emit(WalletSuccess(transactions));
    } catch (e) {
      emit(WalletFailure(e.toString()));
    }
  }
}
