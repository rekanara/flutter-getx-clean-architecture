import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../domain/auth/entities/user_entity.dart';
import '../../../../domain/auth/repositories/auth_repository.dart';
import '../../../../domain/core/errors/failures.dart';
import '../../../platform/secure_storage/flutter_secure_storage_impl.dart';
import '../../../platform/secure_storage/secure_storage.dart';
import '../../../platform/storage/get_storage_impl.dart';
import '../../services/auth_api_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final GetStorageImpl storage;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.apiService,
    required this.storage,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await apiService.login({
        'key': email,
        'password': password,
        'type': 'customer',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];

        if (data == null) {
          return Left(
            ServerFailure(response.data['message'] ?? 'Data not found'),
          );
        }

        final userModel = UserModel.fromJson(data);

        // Simpan token ke SecureStorage (encrypted)
        await secureStorage.write(
          SecureStorageKey.accessToken,
          userModel.accessToken,
        );
        await secureStorage.write(
          SecureStorageKey.refreshToken,
          userModel.refreshToken,
        );

        return Right(userModel);
      } else {
        return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Invalid credentials'),
        );
      }
      return Left(ServerFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error Occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Hapus token dari SecureStorage
      await secureStorage.delete(SecureStorageKey.accessToken);
      await secureStorage.delete(SecureStorageKey.refreshToken);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear secure storage'));
    }
  }
}
