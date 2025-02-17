import 'package:letdem/features/auth/dto/email.dto.dart';
import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/password_reset.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/features/auth/dto/verify_email.dto.dart';
import 'package:letdem/models/auth/tokens.model.dart';

abstract class AuthInterface {
  Future<Tokens> login(LoginDTO loginDTO);
  Future register(RegisterDTO registerDTO);

  Future verifyEmailEvent(VerifyEmailDTO dto);

  Future findForgotPasswordAccount(EmailDTO dto);

  Future resendVerificationCode(EmailDTO dto);

  Future validateResetPassword(VerifyEmailDTO dto);

  Future resetPassword(ResetPasswordDTO dto);
}
