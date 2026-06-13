import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
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

  static const List<Map<String, dynamic>> _staticLanguages = [
    {
      'id': '6a12c216c24497386f0a9bc0',
      'name': 'Amharic',
      'slug': 'amharic',
      'nativeName': 'አማርኛ',
      'summary': 'Foundational Amharic for everyday communication.',
      'description':
          'Structured beginner-to-mastery Amharic curriculum with greetings, daily life, and cultural context.',
      'script': 'Ethiopic',
      'proficiencyLevels': [
        {'code': 'beginner', 'label': 'Beginner', 'order': 1},
        {'code': 'intermediate', 'label': 'Intermediate', 'order': 2},
        {'code': 'advanced', 'label': 'Advanced', 'order': 3}
      ]
    },
    {
      'id': '6a12cc0ea612e8468f3a13f0',
      'name': 'Afan Oromoo',
      'slug': 'oromo',
      'nativeName': 'Afaan Oromoo',
      'summary': 'Foundational Afan Oromoo for everyday communication.',
      'description':
          'Structured beginner-to-mastery Afan Oromoo curriculum with practical vocabulary and dialogues.',
      'script': 'Latin',
      'proficiencyLevels': [
        {'code': 'beginner', 'label': 'Beginner', 'order': 1},
        {'code': 'intermediate', 'label': 'Intermediate', 'order': 2},
        {'code': 'advanced', 'label': 'Advanced', 'order': 3}
      ]
    },
    {
      'id': '6a12cc0fa612e8468f3a1529',
      'name': 'Tigrinya',
      'slug': 'tigrinya',
      'nativeName': 'ትግርኛ',
      'summary': 'Foundational Tigrinya for everyday communication.',
      'description':
          'Structured beginner-to-mastery Tigrinya curriculum with greetings, travel, and community topics.',
      'script': 'Ethiopic',
      'proficiencyLevels': [
        {'code': 'beginner', 'label': 'Beginner', 'order': 1},
        {'code': 'intermediate', 'label': 'Intermediate', 'order': 2},
        {'code': 'advanced', 'label': 'Advanced', 'order': 3}
      ]
    }
  ];

  @override
  Future<Either<Failure, List<dynamic>>> getLanguages() async {
    // Return static bundled list immediately to avoid playstore network delays and layout crashes
    return const Right(_staticLanguages);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLanguageDetail(String languageId) async {
    try {
      // Return static language match if found locally, fallback to remote API otherwise
      final localMatch = _staticLanguages.firstWhere(
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
      return const Left(ServerFailure('Connection failed. This curriculum is not cached for offline use.'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getLessons(String unitId) async {
    try {
      final result = await remoteDataSource.getLessons(unitId);
      final cacheBox = Hive.box('curriculum_cache_box');
      await cacheBox.put('lessons_$unitId', result);
      return Right(result);
    } catch (e) {
      final cacheBox = Hive.box('curriculum_cache_box');
      if (cacheBox.containsKey('lessons_$unitId')) {
        final cached = List<dynamic>.from(cacheBox.get('lessons_$unitId') as List);
        return Right(cached);
      }
      return const Left(ServerFailure('Connection failed. This unit\'s lessons are not cached for offline use.'));
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
      return Right(downloadedUnits);
    } catch (e) {
      return Left(ServerFailure('Failed to retrieve downloaded units: ${e.toString()}'));
    }
  }
}
