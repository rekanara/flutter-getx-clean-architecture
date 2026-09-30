import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/pagination/paginated_result.dart';
import '../entities/contact_entity.dart';

abstract class ContactsRepository {
  Future<Either<Failure, PaginatedResult<ContactEntity>>> getContacts({
    required int page,
    required int limit,
    String? search,
  });
}
