import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/auth/repositories/auth.interface.dart';
import 'package:letdem/models/auth/tokens.model.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

class AuthRepository extends AuthInterface {
  @override
  Future<Tokens> login(LoginDTO loginDTO) async {
    ApiResponse response = await ApiService.sendRequest(
        endpoint: EndPoints.loginEndpoint.copyWithDTO(loginDTO));
    return Tokens(accessToken: response.data['token']);
  }

  @override
  Future register(RegisterDTO registerDTO) async {
    await ApiService.sendRequest(
        endpoint: EndPoints.registerEndpoint.copyWithDTO(registerDTO));
  }

  @override
  Future<Tokens> verifyEmailEvent(VerifyEmailDTO dto) async {
    ApiResponse res = await ApiService.sendRequest(
        endpoint: EndPoints.verifyEmailEndpoint.copyWithDTO(dto));

    return Tokens(accessToken: res.data['token']);
  }

  @override
  Future resendVerificationCode(EmailDTO dto) {
    return ApiService.sendRequest(
        endpoint: EndPoints.resendVerificationCodeEndpoint.copyWithDTO(dto));
  }
}
