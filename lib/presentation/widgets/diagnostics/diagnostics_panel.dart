import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/security/security_bloc.dart';

class DiagnosticsPanel extends StatelessWidget {
  const DiagnosticsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          final diagnostics = state.diagnostics;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security Diagnostics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _DiagnosticRow(
                label: 'Secure Window',
                value: diagnostics.secureWindowEnabled ? 'Enabled' : 'Limited',
                active: diagnostics.secureWindowEnabled,
              ),
              _DiagnosticRow(
                label: 'Screenshot Block',
                value: diagnostics.screenshotBlockEnabled
                    ? 'Active'
                    : 'Limited',
                active: diagnostics.screenshotBlockEnabled,
              ),
              _DiagnosticRow(
                label: 'Recording Detection',
                value: diagnostics.recordingDetectionEnabled
                    ? 'Monitoring'
                    : 'Limited',
                active: diagnostics.recordingDetectionEnabled,
              ),
              _DiagnosticRow(
                label: 'Audio Protection',
                value: diagnostics.audioProtectionEnabled ? 'Secured' : 'Open',
                active: diagnostics.audioProtectionEnabled,
              ),
              _DiagnosticRow(
                label: 'Capture Status',
                value: diagnostics.captureActive ? 'Detected' : 'Clear',
                active: !diagnostics.captureActive,
                inverse: diagnostics.captureActive,
              ),
              if (state.status == SecurityStatus.enabling) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 3),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.active,
    this.inverse = false,
  });

  final String label;
  final String value;
  final bool active;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = inverse
        ? theme.colorScheme.error
        : active
        ? const Color(0xff2f7d4f)
        : theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
