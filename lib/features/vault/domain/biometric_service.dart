import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if the device hardware supports biometrics
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (e) {
      debugPrint("Biometric check failed: $e");
      return false;
    }
  }

  /// Trigger Face ID / Touch ID / Device Passcode authentication
  static Future<bool> authenticate({
    String reason = 'Gunakan Face ID atau sandi untuk membuka Brankas Dokumen',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        // Fallback gracefully if running on simulator or unsupported hardware
        return true;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows passcode fallback if biometric fails
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("Platform error during authentication: $e");
      return false;
    } catch (e) {
      debugPrint("Error during authentication: $e");
      return false;
    }
  }
}
