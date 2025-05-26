import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/token.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/features/auth/models/tokens.model.dart';
import 'package:letdem/features/auth/repositories/auth.interface.dart';
import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/endpoints.dart';
import 'package:letdem/infrastructure/api/api/models/response.model.dart';

class AuthRepository extends AuthInterface {
  @override
  Future<Tokens> login(LoginDTO loginDTO) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.loginEndpoint.copyWithDTO(loginDTO),
    );

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

  @override
  Future findForgotPasswordAccount(EmailDTO dto) {
    return ApiService.sendRequest(
        endpoint: EndPoints.requestForgotPasswordEndpoint.copyWithDTO(dto));
  }

  @override
  Future validateResetPassword(VerifyEmailDTO dto) {
    return ApiService.sendRequest(
        endpoint: EndPoints.resetPasswordEndpoint.copyWithDTO(dto));
  }

  @override
  Future resetPassword(ResetPasswordDTO dto) {
    return ApiService.sendRequest(
        endpoint: EndPoints.resetForgotPasswordEndpoint.copyWithDTO(dto));
  }

  @override
  Future<Tokens> googleLogin(TokenDTO dto) async {
    ApiResponse res = await ApiService.sendRequest(
        endpoint: EndPoints.socialLogin.copyWithDTO(dto));

    return Tokens(accessToken: res.data['token']);
  }

  @override
  Future<Tokens> googleSignup(TokenDTO dto) async {
    ApiResponse res = await ApiService.sendRequest(
        endpoint: EndPoints.socialSignup.copyWithDTO(dto));

    return Tokens(accessToken: res.data['token']);
  }
}
