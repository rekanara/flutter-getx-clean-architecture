import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../domain/core/errors/failures.dart';
import '../../../../domain/home/entities/banner_entity.dart';
import '../../../../domain/home/repositories/home_repository.dart';
import '../../services/home_api_service.dart';
import '../../../../utils/json_parser.dart';
import '../models/banner_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApiService apiService;

  HomeRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final response = await apiService.getBanners();

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        if (data != null) {
          /// Menggunakan JsonParser — otomatis pakai Isolate jika data besar
          final banners = await JsonParser.parseList(
            jsonList: data,
            fromJson: BannerModel.fromJson,
          );
          return Right(banners);
        }
        return const Right([]);
      } else {
        return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error Occurred'));
    }
  }
}
