import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/earning_account/repository/earning.repository.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/views/app/profile/screens/connect_account/connect_account.view.dart';

import 'earning_account_event.dart';

Future<IpApiResponse?> fetchIpApiInfo() async {
  try {
    final response = await http.get(Uri.parse('https://ipapi.co/json/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return IpApiResponse.fromJson(data);
    } else {
      print('Failed to fetch IP info: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching IP info: $e');
    return null;
  }
}

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository repository;

  EarningsBloc({required this.repository}) : super(EarningsInitial()) {
    on<SubmitEarningsAccount>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitAccount(EarningsAccountDTO(
          country: event.dto.country,
          userIp: event.dto.userIp,
          legalFirstName: event.dto.legalFirstName,
          legalLastName: event.dto.legalLastName,
          phone: event.dto.phone,
          birthday: event.dto.birthday,
        ));
        emit(EarningsSuccess());
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsAddress>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitAddress(event.dto);
        emit(EarningsSuccess());
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsDocument>((event, emit) async {
      emit(EarningsLoading());
      try {
        var base64FrontSide = event.frontSide != null
            ? base64Encode(await event.frontSide!.readAsBytes())
            : null;

        var base64BackSide = event.backSide != null
            ? base64Encode(await event.backSide!.readAsBytes())
            : null;

        await repository.submitDocument(
          EarningsDocumentDTO(
            documentType: event.documentType,
            frontSide: base64FrontSide!,
            backSide: base64BackSide!,
          ),
        );
        emit(EarningsSuccess());
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsBankAccount>((event, emit) async {
      emit(EarningsLoading());
      try {
        await repository.submitBankAccount(event.dto);
        emit(EarningsSuccess());
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });
  }
}
