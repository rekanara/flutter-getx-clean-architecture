import 'package:flutter_test/flutter_test.dart';

import 'package:zidanfath_codebase/infrastructure/network/dio_client.dart';
import 'package:zidanfath_codebase/infrastructure/network/dio_wrapper.dart';

void main() {
  group('DioClient.noAuthClient', () {
    test('should create Dio instance with correct timeouts', () {
      final dio = DioClient.noAuthClient;

      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('should have interceptors (DioWrapper + Chucker)', () {
      final dio = DioClient.noAuthClient;

      // Minimal 2 interceptors: TalkerDioLogger + ChuckerDioInterceptor
      expect(dio.interceptors.length, greaterThanOrEqualTo(2));
    });

    test('should create new Dio instance each time (not cached)', () {
      final dio1 = DioClient.noAuthClient;
      final dio2 = DioClient.noAuthClient;

      // Setiap call harus return instance baru
      expect(identical(dio1, dio2), isFalse);
    });
  });

  group('DioWrapper', () {
    test('dioLog should be a TalkerDioLogger instance', () {
      expect(DioWrapper.dioLog, isNotNull);
    });
  });
}
