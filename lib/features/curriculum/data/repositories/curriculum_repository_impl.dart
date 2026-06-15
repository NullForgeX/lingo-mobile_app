import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/constants/static_curriculum_data.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../datasources/curriculum_remote_data_source.dart';
import '../../../practice/data/datasources/practice_remote_data_source.dart';

class CurriculumRepositoryImpl implements CurriculumRepository {
  final CurriculumRemoteDataSource remoteDataSource;
  final PracticeRemoteDataSource practiceRemoteDataSource;

  CurriculumRepositoryImpl({
    required this.remoteDataSource,
    required this.practiceRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<dynamic>>> getLanguages() async {
    // Return static bundled list immediately to avoid playstore network delays and layout crashes
    return const Right(StaticCurriculumData.staticLanguages);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLanguageDetail(String languageId) async {
    try {
      // Return static language match if found locally, fallback to remote API otherwise
      final localMatch = StaticCurriculumData.staticLanguages.firstWhere(
        (lang) => lang['id'] == languageId,
        orElse: () => <String, dynamic>{},
      );
      if (localMatch.isNotEmpty) {
        return Right(localMatch);
      }
      final result = await remoteDataSource.getLanguageDetail(languageId);
      final cacheBox = Hive.box('curriculum_cache_box');
      await cacheBox.put('language_detail_$languageId', result);
      return Right(result);
    } catch (e) {
      final cacheBox = Hive.box('curriculum_cache_box');
      if (cacheBox.containsKey('language_detail_$languageId')) {
        final cached = Map<String, dynamic>.from(cacheBox.get('language_detail_$languageId') as Map);
        return Right(cached);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getUnits(String languageId) async {
    try {
      final result = await remoteDataSource.getUnits(languageId);
      final cacheBox = Hive.box('curriculum_cache_box');
      await cacheBox.put('units_$languageId', result);
      return Right(result);
    } catch (e) {
      final cacheBox = Hive.box('curriculum_cache_box');
      if (cacheBox.containsKey('units_$languageId')) {
        final cached = List<dynamic>.from(cacheBox.get('units_$languageId') as List);
        return Right(cached);
      }
      if (StaticCurriculumData.staticUnits.containsKey(languageId)) {
        final fallback = StaticCurriculumData.staticUnits[languageId]!;
        await cacheBox.put('units_$languageId', fallback);
        return Right(fallback);
      }
      return const Left(ServerFailure('Connection failed. This curriculum is not cached for offline use.'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getLessons(String unitId) async {
    try {
      final result = await remoteDataSource.getLessons(unitId);
      final cacheBox = Hive.box('curriculum_cache_box');
      await cacheBox.put('lessons_$unitId', result);

      // Pre-cache details and runtime questions in the background asynchronously
      _preCacheUnitLessons(result, cacheBox, unitId);

      return Right(result);
    } catch (e) {
      final cacheBox = Hive.box('curriculum_cache_box');
      if (cacheBox.containsKey('lessons_$unitId')) {
        final cached = List<dynamic>.from(cacheBox.get('lessons_$unitId') as List);
        return Right(cached);
      }
      if (StaticCurriculumData.staticLessons.containsKey(unitId)) {
        final fallback = StaticCurriculumData.staticLessons[unitId]!;
        await cacheBox.put('lessons_$unitId', fallback);
        _preCacheStaticLessons(fallback, cacheBox);
        return Right(fallback);
      }
      return const Left(ServerFailure('Connection failed. This unit\'s lessons are not cached for offline use.'));
    }
  }

  void _preCacheUnitLessons(List<dynamic> lessons, Box cacheBox, String unitId) async {
    for (final lesson in lessons) {
      final lessonId = lesson['id'];
      if (lessonId != null) {
        try {
          final detail = await practiceRemoteDataSource.getLessonDetail(lessonId);
          await cacheBox.put('lesson_detail_$lessonId', detail);

          final runtime = await practiceRemoteDataSource.getLessonRuntime(lessonId);
          await cacheBox.put('lesson_runtime_$lessonId', runtime);
        } catch (_) {
          // Suppress pre-cache errors in background
        }
      }
    }

    // Mark the unit as downloaded automatically after background caching
    try {
      final downloadedUnits = List<String>.from(
        cacheBox.get('downloaded_units', defaultValue: <dynamic>[]) as List,
      );
      if (!downloadedUnits.contains(unitId)) {
        downloadedUnits.add(unitId);
        await cacheBox.put('downloaded_units', downloadedUnits);
      }
    } catch (_) {}
  }

  void _preCacheStaticLessons(List<dynamic> lessons, Box cacheBox) {
    for (final lesson in lessons) {
      final lessonId = lesson['id'];
      if (lessonId != null) {
        if (StaticCurriculumData.staticLessonDetails.containsKey(lessonId)) {
          cacheBox.put(
            'lesson_detail_$lessonId',
            StaticCurriculumData.staticLessonDetails[lessonId],
          );
        }
        if (StaticCurriculumData.staticLessonRuntimes.containsKey(lessonId)) {
          cacheBox.put(
            'lesson_runtime_$lessonId',
            StaticCurriculumData.staticLessonRuntimes[lessonId],
          );
        }
      }
    }
  }

  @override
  Future<Either<Failure, User>> selectLanguage(String languageId) async {
    try {
      final userModel = await remoteDataSource.selectLanguage(languageId);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to select language.'));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> downloadUnit(String unitId) async {
    try {
      // 1. Fetch lessons for the unit
      final lessons = await remoteDataSource.getLessons(unitId);
      final cacheBox = Hive.box('curriculum_cache_box');
      await cacheBox.put('lessons_$unitId', lessons);

      // 2. Fetch detail and runtime questions for each lesson
      for (final lesson in lessons) {
        final lessonId = lesson['id'];
        final detail = await practiceRemoteDataSource.getLessonDetail(lessonId);
        await cacheBox.put('lesson_detail_$lessonId', detail);

        final runtime = await practiceRemoteDataSource.getLessonRuntime(lessonId);
        await cacheBox.put('lesson_runtime_$lessonId', runtime);
      }

      // 3. Mark unit as downloaded
      final downloadedUnits = List<String>.from(
        cacheBox.get('downloaded_units', defaultValue: <dynamic>[]) as List,
      );
      if (!downloadedUnits.contains(unitId)) {
        downloadedUnits.add(unitId);
        await cacheBox.put('downloaded_units', downloadedUnits);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to download unit: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDownloadedUnits() async {
    try {
      final cacheBox = Hive.box('curriculum_cache_box');
      final downloadedUnits = List<String>.from(
        cacheBox.get('downloaded_units', defaultValue: <dynamic>[]) as List,
      );
      for (final languageUnits in StaticCurriculumData.staticUnits.values) {
        for (final unit in languageUnits) {
          final unitId = unit['id'] as String;
          if (!downloadedUnits.contains(unitId)) {
            downloadedUnits.add(unitId);
          }
        }
      }
      return Right(downloadedUnits);
    } catch (e) {
      return Left(ServerFailure('Failed to retrieve downloaded units: ${e.toString()}'));
    }
  }
}
