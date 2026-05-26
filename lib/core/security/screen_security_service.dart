import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:screen_protector/screen_protector.dart';

import 'security_diagnostics.dart';
import 'security_service.dart';

class ScreenSecurityService implements SecurityService {
  final _captureController = StreamController<bool>.broadcast();
  SecurityDiagnostics _diagnostics = const SecurityDiagnostics.empty();

  @override
  Future<SecurityDiagnostics> enableSecureMode() async {
    var secureWindowEnabled = false;
    var screenshotBlockEnabled = false;
    var recordingDetectionEnabled = false;

    if (!kIsWeb && Platform.isAndroid) {
      secureWindowEnabled = await _tryFlagSecure();
    }

    screenshotBlockEnabled = await _tryPreventScreenshots();
    secureWindowEnabled = await _tryProtectDataLeakage() || secureWindowEnabled;
    recordingDetectionEnabled = await _tryWatchCapture();

    _diagnostics = SecurityDiagnostics(
      secureWindowEnabled: secureWindowEnabled,
      screenshotBlockEnabled: screenshotBlockEnabled,
      recordingDetectionEnabled: recordingDetectionEnabled,
      audioProtectionEnabled: true,
      captureActive: false,
    );

    return _diagnostics;
  }

  @override
  Future<SecurityDiagnostics> disableSecureMode() async {
    await _safeCall(() => ScreenProtector.preventScreenshotOff());
    await _safeCall(() => ScreenProtector.protectDataLeakageOff());
    await _safeCall(() async => ScreenProtector.removeListener());

    if (!kIsWeb && Platform.isAndroid) {
      await _safeCall(
        () => FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE),
      );
    }

    _diagnostics = const SecurityDiagnostics.empty();
    return _diagnostics;
  }

  @override
  Stream<bool> captureStatus() {
    return _captureController.stream.distinct();
  }

  Future<bool> _tryFlagSecure() async {
    try {
      return FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _tryPreventScreenshots() async {
    return _safeCall(() => ScreenProtector.preventScreenshotOn());
  }

  Future<bool> _tryProtectDataLeakage() async {
    return _safeCall(() => ScreenProtector.protectDataLeakageOn());
  }

  Future<bool> _tryWatchCapture() async {
    try {
      ScreenProtector.addListener(
        () => _captureController.add(true),
        (captured) => _captureController.add(captured),
      );

      if (!kIsWeb && Platform.isIOS) {
        _captureController.add(await ScreenProtector.isRecording());
      } else {
        _captureController.add(false);
      }

      return true;
    } on MissingPluginException {
      return !kIsWeb && Platform.isAndroid && _diagnostics.secureWindowEnabled;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _safeCall(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
