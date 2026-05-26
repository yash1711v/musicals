import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/security/security_diagnostics.dart';
import '../../../core/security/security_service.dart';

enum SecurityStatus { initial, enabling, secured, degraded }

sealed class SecurityEvent extends Equatable {
  const SecurityEvent();

  @override
  List<Object?> get props => [];
}

final class SecurityStarted extends SecurityEvent {
  const SecurityStarted();
}

final class SecurityCaptureChanged extends SecurityEvent {
  const SecurityCaptureChanged(this.captureActive);

  final bool captureActive;

  @override
  List<Object?> get props => [captureActive];
}

class SecurityState extends Equatable {
  const SecurityState({
    required this.status,
    required this.diagnostics,
    required this.errorMessage,
  });

  const SecurityState.initial()
    : status = SecurityStatus.initial,
      diagnostics = const SecurityDiagnostics.empty(),
      errorMessage = null;

  final SecurityStatus status;
  final SecurityDiagnostics diagnostics;
  final String? errorMessage;

  SecurityState copyWith({
    SecurityStatus? status,
    SecurityDiagnostics? diagnostics,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SecurityState(
      status: status ?? this.status,
      diagnostics: diagnostics ?? this.diagnostics,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, diagnostics, errorMessage];
}

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  SecurityBloc({required SecurityService securityService})
    : _securityService = securityService,
      super(const SecurityState.initial()) {
    on<SecurityStarted>(_onSecurityStarted);
    on<SecurityCaptureChanged>(_onSecurityCaptureChanged);
  }

  final SecurityService _securityService;
  StreamSubscription<bool>? _captureSubscription;

  Future<void> _onSecurityStarted(
    SecurityStarted event,
    Emitter<SecurityState> emit,
  ) async {
    emit(state.copyWith(status: SecurityStatus.enabling, clearError: true));

    try {
      final diagnostics = await _securityService.enableSecureMode();
      await _captureSubscription?.cancel();
      _captureSubscription = _securityService.captureStatus().listen(
        (captureActive) => add(SecurityCaptureChanged(captureActive)),
      );

      emit(
        state.copyWith(
          status:
              diagnostics.secureWindowEnabled ||
                  diagnostics.screenshotBlockEnabled
              ? SecurityStatus.secured
              : SecurityStatus.degraded,
          diagnostics: diagnostics,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SecurityStatus.degraded,
          errorMessage: 'Secure mode is partially available',
        ),
      );
    }
  }

  void _onSecurityCaptureChanged(
    SecurityCaptureChanged event,
    Emitter<SecurityState> emit,
  ) {
    emit(
      state.copyWith(
        diagnostics: state.diagnostics.copyWith(
          captureActive: event.captureActive,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _captureSubscription?.cancel();
    await _securityService.disableSecureMode();
    return super.close();
  }
}
