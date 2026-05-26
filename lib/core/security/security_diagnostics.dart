import 'package:equatable/equatable.dart';

class SecurityDiagnostics extends Equatable {
  const SecurityDiagnostics({
    required this.secureWindowEnabled,
    required this.screenshotBlockEnabled,
    required this.recordingDetectionEnabled,
    required this.audioProtectionEnabled,
    required this.captureActive,
  });

  const SecurityDiagnostics.empty()
    : secureWindowEnabled = false,
      screenshotBlockEnabled = false,
      recordingDetectionEnabled = false,
      audioProtectionEnabled = false,
      captureActive = false;

  final bool secureWindowEnabled;
  final bool screenshotBlockEnabled;
  final bool recordingDetectionEnabled;
  final bool audioProtectionEnabled;
  final bool captureActive;

  SecurityDiagnostics copyWith({
    bool? secureWindowEnabled,
    bool? screenshotBlockEnabled,
    bool? recordingDetectionEnabled,
    bool? audioProtectionEnabled,
    bool? captureActive,
  }) {
    return SecurityDiagnostics(
      secureWindowEnabled: secureWindowEnabled ?? this.secureWindowEnabled,
      screenshotBlockEnabled:
          screenshotBlockEnabled ?? this.screenshotBlockEnabled,
      recordingDetectionEnabled:
          recordingDetectionEnabled ?? this.recordingDetectionEnabled,
      audioProtectionEnabled:
          audioProtectionEnabled ?? this.audioProtectionEnabled,
      captureActive: captureActive ?? this.captureActive,
    );
  }

  @override
  List<Object> get props => [
    secureWindowEnabled,
    screenshotBlockEnabled,
    recordingDetectionEnabled,
    audioProtectionEnabled,
    captureActive,
  ];
}
