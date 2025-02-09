import 'package:letdem/features/auth/dto/login.dto.dart';
import 'package:letdem/features/auth/dto/register.dto.dart';
import 'package:letdem/models/auth/tokens.model.dart';

abstract class AuthInterface {
  Future<Tokens> login(LoginDTO loginDTO);
  Future register(RegisterDTO registerDTO);
}
