import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/banner_entity.dart';
import '../repositories/home_repository.dart';

class GetBannersUseCase extends UseCase<List<BannerEntity>, NoParams> {
  final HomeRepository repository;

  GetBannersUseCase(this.repository);

  @override
  Future<Either<Failure, List<BannerEntity>>> execute(NoParams params) {
    return repository.getBanners();
  }
}
