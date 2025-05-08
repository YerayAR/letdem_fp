import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/earning_account_state.dart';
import 'package:letdem/features/earning_account/repository/earning.repository.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/views/app/profile/screens/connect_account/connect_account.view.dart';

import 'earning_account_event.dart';

String getCountryCodeFromLocale() {
  return ui.window.locale.countryCode ?? "ES";
}

Future<IpApiResponse?> fetchIpApiInfo() async {
  try {
    final response = await http.get(Uri.parse('https://ipwho.is'));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

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
        // Fetch IP information
        final ipInfo = await fetchIpApiInfo();

        if (ipInfo == null) {
          emit(const EarningsFailure("Failed to fetch IP information."));
          return;
        }

        var account = await repository.submitAccount(EarningsAccountDTO(
          country: "ES",
          userIp: ipInfo.ip,
          legalFirstName: event.legalFirstName,
          legalLastName: event.legalLastName,
          phone: event.phone,
          birthday: event.birthday,
        ));
        emit(EarningsSuccess(account));
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsAddress>((event, emit) async {
      emit(EarningsLoading());
      try {
        var account = await repository.submitAddress(event.dto);
        emit(EarningsSuccess(account));
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

        var account = await repository.submitDocument(
          EarningsDocumentDTO(
            documentType: event.documentType,
            frontSide: base64FrontSide!,
            backSide: base64BackSide!,
          ),
        );
        emit(EarningsSuccess(account));
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });

    on<SubmitEarningsBankAccount>((event, emit) async {
      emit(EarningsLoading());
      try {
        var account = await repository.submitBankAccount(event.dto);
        emit(EarningsCompleted(account));
      } on ApiError catch (er) {
        emit(EarningsFailure(er.message));
      } catch (e) {
        emit(EarningsFailure(e.toString()));
      }
    });
  }
}
