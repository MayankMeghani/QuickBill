import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCredential(String password) async {
    await _storage.write(key: 'password', value: password);
  }

  Future<void> saveCredentials() async {
    String ?email=_auth.currentUser?.email;
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'isBiometricEnabled', value: 'true');
  }

  Future<Map<String, String?>> getCredentials() async {
    final email = await _storage.read(key: 'email');
    final isBiometricEnabled = await _storage.read(key: 'isBiometricEnabled');
    final password = await _storage.read(key: 'password');
    return {'email': email,'password' :password ,'isBiometricEnabled': isBiometricEnabled};
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool flag = await _localAuth.canCheckBiometrics;
      bool isSupported = await _localAuth
          .isDeviceSupported();
      if (!flag || !isSupported) {
        return false;
      }

      final bool didAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      return didAuthenticated;
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }
}