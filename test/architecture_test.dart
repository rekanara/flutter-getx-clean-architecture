import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Test ini menjaga aturan batas layer Clean Architecture.
/// Dijalankan setiap kali CI (flutter test) dipanggil.
/// Jika ada import yang melanggar aturan, CI akan gagal.
void main() {
  group('Clean Architecture Layer Boundaries', () {
    test('Domain layer MUST NOT import infrastructure or presentation', () {
      final domainDir = Directory('lib/domain');
      if (!domainDir.existsSync()) return;

      final files = domainDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        final lines = file.readAsLinesSync();
        final path = file.path;

        for (final line in lines) {
          if (!line.trim().startsWith('import ')) continue;

          // Domain tidak boleh tau soal infrastruktur
          final hasInfraImport =
              line.contains('/infrastructure/') ||
              line.contains('package:rekanara_getx/infrastructure/');
          expect(
            hasInfraImport,
            isFalse,
            reason:
                'Domain layer must not import infrastructure ($path: $line)',
          );

          // Domain tidak boleh tau soal presentasi
          final hasPresentationImport =
              line.contains('/presentation/') ||
              line.contains('package:rekanara_getx/presentation/');
          expect(
            hasPresentationImport,
            isFalse,
            reason: 'Domain layer must not import presentation ($path: $line)',
          );

          // Domain harus murni Dart, tidak boleh ada Flutter UI
          final hasFlutterImport = line.contains('package:flutter/');
          expect(
            hasFlutterImport,
            isFalse,
            reason:
                'Domain layer should be pure Dart, no Flutter imports ($path: $line)',
          );

          // Domain tidak boleh depend pada state management GetX
          final hasGetImport = line.contains('package:get/');
          expect(
            hasGetImport,
            isFalse,
            reason:
                'Domain layer should be pure Dart, no GetX imports ($path: $line)',
          );
        }
      }
    });

    test('Infrastructure layer MUST NOT import presentation', () {
      final infraDir = Directory('lib/infrastructure');
      if (!infraDir.existsSync()) return;

      final files = infraDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        final lines = file.readAsLinesSync();
        final path = file.path;

        // Pengecualian: Folder navigation memang bertugas me-wiring Controller dan Screen (di layer presentation).
        if (path.contains('infrastructure/navigation/')) continue;

        for (final line in lines) {
          if (!line.trim().startsWith('import ')) continue;

          // Infra tidak boleh menyentuh UI (controllers/screens)
          final hasPresentationImport =
              line.contains('/presentation/') ||
              line.contains('package:rekanara_getx/presentation/');
          expect(
            hasPresentationImport,
            isFalse,
            reason:
                'Infrastructure layer must not import presentation ($path: $line)',
          );
        }
      }
    });
  });
}
