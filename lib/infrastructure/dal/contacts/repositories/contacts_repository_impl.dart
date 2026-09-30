import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../domain/contacts/entities/contact_entity.dart';
import '../../../../domain/contacts/repositories/contacts_repository.dart';
import '../../../../domain/core/errors/failures.dart';
import '../../../../domain/core/pagination/paginated_result.dart';
import '../../../../utils/json_parser.dart';
import '../../models/api_response.dart';
import '../../models/pagination_filter.dart';
import '../../services/contacts_api_service.dart';
import '../models/contact_model.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsApiService apiService;

  ContactsRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, PaginatedResult<ContactEntity>>> getContacts({
    required int page,
    required int limit,
    String? search,
  }) async {
    final filter = PaginationFilter(page: page, limit: limit, search: search);

    try {
      final response = await apiService.getContacts(filter);

      if (response.statusCode != 200) {
        return Left(ServerFailure(response.statusMessage ?? 'Server Error'));
      }

      // dummyjson.com tidak mengikuti kontrak standar {success, data, meta}
      // (lihat api_response.dart) — jadi meta di-bangun manual dari
      // total/skip/limit. Kalau backend kamu sudah mengikuti kontrak standar,
      // pakai `ApiResponse.fromJsonList` + `PaginationMeta.fromJson` langsung
      // seperti dijelaskan di `.agents/skills/api-service/SKILL.md`.
      final rawUsers = response.data['users'] as List? ?? [];
      final total = response.data['total'] as int? ?? 0;
      final meta = PaginationMeta(
        currentPage: page,
        lastPage: limit == 0 ? 1 : (total / limit).ceil().clamp(1, 999999),
        perPage: limit,
        total: total,
      );

      final contacts = await JsonParser.parseList(
        jsonList: rawUsers,
        fromJson: ContactModel.fromJson,
      );

      return Right(
        PaginatedResult(
          items: contacts,
          currentPage: meta.currentPage,
          lastPage: meta.lastPage,
          total: meta.total,
        ),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected Error Occurred'));
    }
  }
}
