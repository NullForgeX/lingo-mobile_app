import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class GetAdminUsers {
  final AdminRepository repository;

  GetAdminUsers(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int page,
    required int pageSize,
    String? search,
    String? role,
    String? status,
    String? sort,
    String? order,
  }) {
    return repository.getUsers(
      page: page,
      pageSize: pageSize,
      search: search,
      role: role,
      status: status,
      sort: sort,
      order: order,
    );
  }
}
