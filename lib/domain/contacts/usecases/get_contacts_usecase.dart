import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/pagination/paginated_result.dart';
import '../../core/usecases/usecase.dart';
import '../entities/contact_entity.dart';
import '../repositories/contacts_repository.dart';

class GetContactsParams {
  final int page;
  final int limit;
  final String? search;

  const GetContactsParams({this.page = 1, this.limit = 15, this.search});
}

class GetContactsUseCase
    extends UseCase<PaginatedResult<ContactEntity>, GetContactsParams> {
  final ContactsRepository repository;

  GetContactsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedResult<ContactEntity>>> execute(
    GetContactsParams params,
  ) {
    return repository.getContacts(
      page: params.page,
      limit: params.limit,
      search: params.search,
    );
  }
}
