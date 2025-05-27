import 'package:letdem/infrastructure/storage/storage/storage.service.dart';

class Tokens {
  final String accessToken;

  Tokens({required this.accessToken});

  write() async {
    await SecureStorageHelper().write('access_token', accessToken);
  }

  static delete() async {
    await SecureStorageHelper().delete('access_token');
  }
}
