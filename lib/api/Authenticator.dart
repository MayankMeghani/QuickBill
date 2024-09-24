import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveCredential(String email,String password) async {
    try {
      QuerySnapshot shopQuery = await firestore
          .collection('shops')
          .where('email', isEqualTo: email)
          .get(); // Fetch query result

      if (shopQuery.docs.isNotEmpty) { // Check if any documents are returned
        DocumentSnapshot shopDoc = shopQuery.docs.first; // Get the first document

        bool isBiometricEnabled = shopDoc.get('isBiometricEnabled') ?? false;

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isBiometricEnabled', isBiometricEnabled);
      } else {
      print('Shop document not found for email: $email');
    }
  } catch (e) {
  print('Error saving credential and updating biometric status: $e');
  }
  }

  Future<void> saveCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String ?email=_auth.currentUser?.email;
    await _storage.write(key: 'email', value: email);
    await prefs.setBool('isBiometricEnabled', true);
  }
  Future<void> removeCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await _storage.delete(key: 'email');
    await prefs.setBool('isBiometricEnabled', false);

  }
  Future<Map<String, String?>> getCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = await prefs.getBool('isBiometricEnabled');
    if(isBiometricEnabled == true){
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');
      return {'email': email,'password' :password ,'isBiometricEnabled': '$isBiometricEnabled'};
    }
    return {'isBiometricEnabled':'$isBiometricEnabled'};
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