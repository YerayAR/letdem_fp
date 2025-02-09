import 'package:letdem/services/storage/storage.service.dart';

class Tokens {
  final String accessToken;

  Tokens({required this.accessToken});

  write() async {
    await SecureStorageHelper().write('access_token', accessToken);
  }
}
