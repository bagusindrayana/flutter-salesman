import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageProvider {
  //save token to FlutterSecureStorage
  static Future<void> persistToken(String token) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
  }

  //get token
  static Future<String?> getToken() async {
    final storage = new FlutterSecureStorage();
    return await storage.read(key: 'token');
  }
}
