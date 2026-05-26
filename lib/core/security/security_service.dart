import 'security_diagnostics.dart';

abstract class SecurityService {
  Future<SecurityDiagnostics> enableSecureMode();

  Future<SecurityDiagnostics> disableSecureMode();

  Stream<bool> captureStatus();
}
