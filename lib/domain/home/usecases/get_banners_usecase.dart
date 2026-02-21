import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/banner_entity.dart';
import '../repositories/home_repository.dart';

class GetBannersUseCase {
  final HomeRepository repository;

  GetBannersUseCase(this.repository);

  Future<Either<Failure, List<BannerEntity>>> execute() {
    return repository.getBanners();
  }
}
