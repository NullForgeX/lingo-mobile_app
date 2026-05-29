import 'package:get_it/get_it.dart';

import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/update_user_profile.dart';
import 'features/auth/domain/usecases/get_user_profile.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/curriculum/domain/usecases/select_language.dart';

import 'features/practice/data/datasources/practice_remote_data_source.dart';
import 'features/practice/data/repositories/practice_repository_impl.dart';
import 'features/practice/domain/repositories/practice_repository.dart';
import 'features/practice/presentation/bloc/practice_bloc.dart';

import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

import 'features/curriculum/data/datasources/curriculum_remote_data_source.dart';
import 'features/curriculum/data/repositories/curriculum_repository_impl.dart';
import 'features/curriculum/domain/repositories/curriculum_repository.dart';
import 'features/curriculum/presentation/bloc/curriculum_bloc.dart';

import 'features/admin/data/datasources/admin_remote_data_source.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/domain/usecases/create_admin_user.dart';
import 'features/admin/domain/usecases/get_admin_user_detail.dart';
import 'features/admin/domain/usecases/get_admin_users.dart';
import 'features/admin/domain/usecases/reactivate_user.dart';
import 'features/admin/domain/usecases/revoke_user_sessions.dart';
import 'features/admin/domain/usecases/suspend_user.dart';
import 'features/admin/domain/usecases/update_admin_user.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final dioClient = DioClient();
  await dioClient.init();
  sl.registerLazySingleton(() => dioClient.dio);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PracticeRemoteDataSource>(
    () => PracticeRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<PracticeRepository>(
    () => PracticeRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CurriculumRemoteDataSource>(
    () => CurriculumRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<CurriculumRepository>(
    () => CurriculumRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => SelectLanguage(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      updateUserProfile: sl(),
      getUserProfile: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => PracticeBloc(repository: sl()),
  );

  sl.registerFactory(
    () => HomeBloc(repository: sl()),
  );

  sl.registerFactory(
    () => CurriculumBloc(repository: sl()),
  );

  // Admin Data Sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(dio: sl()),
  );

  // Admin Repositories
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  // Admin Use Cases
  sl.registerLazySingleton(() => GetAdminUsers(sl()));
  sl.registerLazySingleton(() => GetAdminUserDetail(sl()));
  sl.registerLazySingleton(() => CreateAdminUser(sl()));
  sl.registerLazySingleton(() => UpdateAdminUser(sl()));
  sl.registerLazySingleton(() => SuspendUser(sl()));
  sl.registerLazySingleton(() => ReactivateUser(sl()));
  sl.registerLazySingleton(() => RevokeUserSessions(sl()));

  // Admin BLoC
  sl.registerFactory(
    () => AdminBloc(
      getAdminUsers: sl(),
      getAdminUserDetail: sl(),
      createAdminUser: sl(),
      updateAdminUser: sl(),
      suspendUser: sl(),
      reactivateUser: sl(),
      revokeUserSessions: sl(),
    ),
  );
}
