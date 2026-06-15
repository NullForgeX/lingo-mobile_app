import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/practice_repository.dart';
import '../../domain/entities/attempt.dart';

abstract class PracticeEvent {}

class GetRuntimeEvent extends PracticeEvent {
  final String lessonId;
  GetRuntimeEvent(this.lessonId);
}

class StartAttemptEvent extends PracticeEvent {
  final String lessonId;
  final List<dynamic> exercises;
  StartAttemptEvent(this.lessonId, this.exercises);
}

class StartExerciseAttemptEvent extends PracticeEvent {
  final String exerciseId;
  final Map<String, dynamic> exercise;
  StartExerciseAttemptEvent(this.exerciseId, this.exercise);
}

class ListAttemptsEvent extends PracticeEvent {
  final int page;
  final int pageSize;
  final String order;
  ListAttemptsEvent({this.page = 1, this.pageSize = 20, this.order = 'desc'});
}

class AbandonAttemptEvent extends PracticeEvent {
  final String attemptId;
  AbandonAttemptEvent(this.attemptId);
}

class SubmitAttemptEvent extends PracticeEvent {
  final String attemptId;
  final List<Map<String, dynamic>> answers;
  SubmitAttemptEvent(this.attemptId, this.answers);
}

abstract class PracticeState {}

class PracticeInitial extends PracticeState {}
class PracticeLoading extends PracticeState {}

class RuntimeLoaded extends PracticeState {
  final Map<String, dynamic> lesson;
  final Map<String, dynamic> runtime;
  RuntimeLoaded(this.lesson, this.runtime);
}

class AttemptStarted extends PracticeState {
  final String attemptId;
  final List<dynamic> exercises;
  AttemptStarted(this.attemptId, this.exercises);
}

class AttemptSubmitted extends PracticeState {
  final Map<String, dynamic> result;
  AttemptSubmitted(this.result);
}

class AttemptsListLoaded extends PracticeState {
  final Map<String, dynamic> attemptsData;
  AttemptsListLoaded(this.attemptsData);
}

class AttemptAbandoned extends PracticeState {
  final QuizAttempt attempt;
  AttemptAbandoned(this.attempt);
}

class PracticeError extends PracticeState {
  final String message;
  PracticeError(this.message);
}

class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final PracticeRepository repository;
  
  List<dynamic>? _currentExercises;
  String? _currentLessonId;
  String? _currentLessonTitle;
  String? _currentLanguageName;

  PracticeBloc({required this.repository}) : super(PracticeInitial()) {
    on<GetRuntimeEvent>((event, emit) async {
      emit(PracticeLoading());
      final lessonResult = await repository.getLessonDetail(event.lessonId);
      final runtimeResult = await repository.getLessonRuntime(event.lessonId);

      String? errorMessage;
      Map<String, dynamic>? lesson;
      Map<String, dynamic>? runtime;

      lessonResult.fold(
        (failure) => errorMessage = failure.message,
        (data) => lesson = data,
      );

      if (errorMessage != null) {
        emit(PracticeError(errorMessage!));
        return;
      }

      runtimeResult.fold(
        (failure) => errorMessage = failure.message,
        (data) => runtime = data,
      );

      if (errorMessage != null) {
        emit(PracticeError(errorMessage!));
        return;
      }

      // Cache metadata
      _currentLessonId = event.lessonId;
      _currentLessonTitle = lesson?['title'] ?? 'Lesson Practice';
      _currentLanguageName = lesson?['languageName'];

      emit(RuntimeLoaded(lesson!, runtime!));
    });

    on<StartAttemptEvent>((event, emit) async {
      emit(PracticeLoading());
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        _currentExercises = event.exercises;
        final mockAttemptId = 'guest_attempt_${DateTime.now().millisecondsSinceEpoch}';
        emit(AttemptStarted(mockAttemptId, event.exercises));
        return;
      }
      final result = await repository.startLessonAttempt(event.lessonId);
      result.fold(
        (failure) {
          _currentExercises = event.exercises;
          final mockAttemptId = 'offline_attempt_${DateTime.now().millisecondsSinceEpoch}';
          emit(AttemptStarted(mockAttemptId, event.exercises));
        },
        (attempt) => emit(AttemptStarted(attempt.id, event.exercises)),
      );
    });

    on<StartExerciseAttemptEvent>((event, emit) async {
      emit(PracticeLoading());
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        _currentExercises = [event.exercise];
        final mockAttemptId = 'guest_attempt_${DateTime.now().millisecondsSinceEpoch}';
        emit(AttemptStarted(mockAttemptId, [event.exercise]));
        return;
      }
      final result = await repository.startExerciseAttempt(event.exerciseId);
      result.fold(
        (failure) {
          _currentExercises = [event.exercise];
          final mockAttemptId = 'offline_attempt_${DateTime.now().millisecondsSinceEpoch}';
          emit(AttemptStarted(mockAttemptId, [event.exercise]));
        },
        (attempt) => emit(AttemptStarted(attempt.id, [event.exercise])),
      );
    });

    on<ListAttemptsEvent>((event, emit) async {
      emit(PracticeLoading());
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        // Guest user attempts list loading from Hive
        final attemptsBox = Hive.box('guest_attempts_box');
        final items = attemptsBox.values.map((v) => Map<String, dynamic>.from(v as Map)).toList().reversed.toList();
        emit(AttemptsListLoaded({
          'items': items,
          'total': items.length,
          'page': 1,
          'pageSize': event.pageSize,
        }));
        return;
      }
      final result = await repository.listAttempts(
        page: event.page,
        pageSize: event.pageSize,
        order: event.order,
      );
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (attemptsData) => emit(AttemptsListLoaded(attemptsData)),
      );
    });

    on<AbandonAttemptEvent>((event, emit) async {
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        emit(AttemptAbandoned(QuizAttempt(id: event.attemptId, status: 'abandoned', attemptNumber: 1)));
        return;
      }
      if (!isClosed) emit(PracticeLoading());
      final result = await repository.abandonAttempt(event.attemptId);
      if (!isClosed) {
        result.fold(
          (failure) => emit(PracticeError(failure.message)),
          (attempt) => emit(AttemptAbandoned(attempt)),
        );
      }
    });

    on<SubmitAttemptEvent>((event, emit) async {
      emit(PracticeLoading());
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      final isOfflineAttempt = event.attemptId.startsWith('offline_attempt_');
      if (isGuest || isOfflineAttempt) {
        final exercises = _currentExercises ?? [];
        final answers = event.answers;

        int correctCount = 0;
        final List<Map<String, dynamic>> feedbackList = [];
        final List<Map<String, dynamic>> syncAnswers = [];

        for (final answer in answers) {
          final exerciseId = answer['exerciseId'];
          final type = answer['type'];

          final exercise = exercises.firstWhere(
            (e) => e['id'] == exerciseId,
            orElse: () => null,
          );

          if (exercise == null) continue;

          bool isCorrect = false;
          final List<dynamic> correctOptionIds = exercise['correctOptionIds'] as List<dynamic>? ?? [];
          final List<dynamic> acceptedAnswers = exercise['acceptedAnswers'] as List<dynamic>? ?? [];

          if (type == 'multiple_choice' || type == 'listening') {
            final submittedOptionIds = answer['selectedOptionIds'] as List<dynamic>? ?? [];
            if (submittedOptionIds.isNotEmpty && correctOptionIds.isNotEmpty) {
              isCorrect = submittedOptionIds.length == correctOptionIds.length &&
                  submittedOptionIds.every((id) => correctOptionIds.contains(id));
            }
            syncAnswers.add({
              'exerciseId': exerciseId,
              'isCorrect': isCorrect,
              'selectedOptionIds': submittedOptionIds,
            });
          } else {
            // Trim outer spaces, lowercase, and normalize consecutive whitespaces into a single space
            final responseStr = (answer['response'] as String? ?? '')
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ')
                .toLowerCase();
            isCorrect = acceptedAnswers.any((ans) =>
                ans.toString().trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase() == responseStr);
            syncAnswers.add({
              'exerciseId': exerciseId,
              'isCorrect': isCorrect,
              'response': answer['response'] ?? '',
            });
          }

          if (isCorrect) {
            correctCount++;
          }

          feedbackList.add({
            'exerciseId': exerciseId,
            'isCorrect': isCorrect,
            'explanation': exercise['explanation'] ?? '',
            'type': type,
            'submittedAnswer': answer,
            'correctOptionIds': correctOptionIds,
            'acceptedAnswers': acceptedAnswers,
          });
        }

        final maxScore = exercises.length;
        final double successPercentage = maxScore > 0 ? (correctCount / maxScore) * 100 : 0;
        final passed = successPercentage >= 70;
        final xpEarned = (passed ? 10 : 0) + correctCount;

        final attemptResult = {
          'id': event.attemptId,
          'status': 'completed',
          'attemptNumber': 1,
          'scoreSummary': {
            'score': correctCount,
            'maxScore': maxScore,
            'passed': passed,
            'xpEarned': xpEarned,
          },
        };

        final resultPayload = {
          'attempt': attemptResult,
          'feedback': feedbackList,
        };

        final String lessonId = _currentLessonId ?? 'unknown';
        final String lessonTitle = _currentLessonTitle ?? 'Lesson Practice';

        final attemptRecordToSave = {
          'lessonId': lessonId,
          'lessonTitle': lessonTitle,
          'score': correctCount,
          'maxScore': maxScore,
          'passed': passed,
          'xpEarned': xpEarned,
          'startedAt': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          'completedAt': DateTime.now().toIso8601String(),
          'answers': syncAnswers,
        };

        if (isGuest) {
          // Save locally
          final attemptsBox = Hive.box('guest_attempts_box');
          await attemptsBox.add(attemptRecordToSave);

          // Update dashboard details
          final dashboardBox = Hive.box('guest_dashboard_box');
          final dashboard = Map<String, dynamic>.from(dashboardBox.get('dashboard', defaultValue: <String, dynamic>{}) as Map);

          if (dashboard.isEmpty) {
            dashboard['streak'] = {'currentDays': 0, 'lastActiveDate': ''};
            dashboard['xp'] = {
              'totalXp': 0,
              'lessonCompletionXp': 0,
              'assessmentXp': 0,
              'badgeXp': 0,
            };
            dashboard['progress'] = <dynamic>[];
            dashboard['recentAttempts'] = <dynamic>[];
          }

          final xp = Map<String, dynamic>.from((dashboard['xp'] ?? <String, dynamic>{}) as Map);
          xp['totalXp'] = (xp['totalXp'] ?? 0) + xpEarned;
          xp['lessonCompletionXp'] = (xp['lessonCompletionXp'] ?? 0) + xpEarned;
          dashboard['xp'] = xp;

          final streak = Map<String, dynamic>.from((dashboard['streak'] ?? <String, dynamic>{}) as Map);
          final lastActiveStr = streak['lastActiveDate'] as String? ?? '';
          final now = DateTime.now();
          final todayStr = '${now.year}-${now.month}-${now.day}';

          if (lastActiveStr != todayStr) {
            int curDays = streak['currentDays'] ?? 0;
            if (lastActiveStr.isNotEmpty) {
              try {
                final lastActiveDate = DateTime.parse(lastActiveStr);
                final difference = now.difference(lastActiveDate).inDays;
                if (difference == 1) {
                  curDays += 1;
                } else if (difference > 1) {
                  curDays = 1;
                }
              } catch (_) {
                curDays = 1;
              }
            } else {
              curDays = 1;
            }
            streak['currentDays'] = curDays;
            streak['lastActiveDate'] = todayStr;
            dashboard['streak'] = streak;
          }

          final progressList = List<dynamic>.from(dashboard['progress'] ?? []);
          final progressIndex = progressList.indexWhere((p) => p['lessonId'] == lessonId);
          final progressEntry = {
            'lessonId': lessonId,
            'lessonTitle': lessonTitle,
            'languageName': _currentLanguageName ?? 'Abyssinian Language',
            'completionPercentage': successPercentage,
          };
          if (progressIndex >= 0) {
            progressList[progressIndex] = progressEntry;
          } else {
            progressList.insert(0, progressEntry);
          }
          dashboard['progress'] = progressList;

          final recentAttemptsList = List<dynamic>.from(dashboard['recentAttempts'] ?? []);
          final recentAttemptEntry = {
            'id': event.attemptId,
            'lessonId': lessonId,
            'lessonTitle': lessonTitle,
            'scoreSummary': {
              'percentage': successPercentage,
            },
            'startedAt': DateTime.now().toIso8601String(),
          };
          recentAttemptsList.insert(0, recentAttemptEntry);
          if (recentAttemptsList.length > 5) {
            recentAttemptsList.removeLast();
          }
          dashboard['recentAttempts'] = recentAttemptsList;

          await dashboardBox.put('dashboard', dashboard);
        } else {
          // Save locally for auth offline attempts
          final attemptsBox = Hive.box('auth_attempts_box');
          await attemptsBox.add(attemptRecordToSave);

          // Update auth cached dashboard details
          final dashboardBox = Hive.box('auth_dashboard_box');
          final dashboard = Map<String, dynamic>.from(dashboardBox.get('dashboard', defaultValue: <String, dynamic>{}) as Map);

          if (dashboard.isNotEmpty) {
            final xp = Map<String, dynamic>.from((dashboard['xp'] ?? <String, dynamic>{}) as Map);
            xp['totalXp'] = (xp['totalXp'] ?? 0) + xpEarned;
            xp['lessonCompletionXp'] = (xp['lessonCompletionXp'] ?? 0) + xpEarned;
            dashboard['xp'] = xp;

            final streak = Map<String, dynamic>.from((dashboard['streak'] ?? <String, dynamic>{}) as Map);
            final lastActiveStr = streak['lastActiveDate'] as String? ?? '';
            final now = DateTime.now();
            final todayStr = '${now.year}-${now.month}-${now.day}';

            if (lastActiveStr != todayStr) {
              int curDays = streak['currentDays'] ?? 0;
              if (lastActiveStr.isNotEmpty) {
                try {
                  final lastActiveDate = DateTime.parse(lastActiveStr);
                  final difference = now.difference(lastActiveDate).inDays;
                  if (difference == 1) {
                    curDays += 1;
                  } else if (difference > 1) {
                    curDays = 1;
                  }
                } catch (_) {
                  curDays = 1;
                }
              } else {
                curDays = 1;
              }
              streak['currentDays'] = curDays;
              streak['lastActiveDate'] = todayStr;
              dashboard['streak'] = streak;
            }

            final progressList = List<dynamic>.from(dashboard['progress'] ?? []);
            final progressIndex = progressList.indexWhere((p) => p['lessonId'] == lessonId);
            final progressEntry = {
              'lessonId': lessonId,
              'lessonTitle': lessonTitle,
              'languageName': _currentLanguageName ?? 'Language',
              'completionPercentage': successPercentage,
            };
            if (progressIndex >= 0) {
              progressList[progressIndex] = progressEntry;
            } else {
              progressList.insert(0, progressEntry);
            }
            dashboard['progress'] = progressList;

            final recentAttemptsList = List<dynamic>.from(dashboard['recentAttempts'] ?? []);
            final recentAttemptEntry = {
              'id': event.attemptId,
              'lessonId': lessonId,
              'lessonTitle': lessonTitle,
              'scoreSummary': {
                'percentage': successPercentage,
              },
              'startedAt': DateTime.now().toIso8601String(),
            };
            recentAttemptsList.insert(0, recentAttemptEntry);
            if (recentAttemptsList.length > 5) {
              recentAttemptsList.removeLast();
            }
            dashboard['recentAttempts'] = recentAttemptsList;

            await dashboardBox.put('dashboard', dashboard);
          }
        }

        emit(AttemptSubmitted(resultPayload));
        return;
      }

      final result = await repository.submitAttempt(event.attemptId, event.answers);
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (submitResult) => emit(AttemptSubmitted(submitResult)),
      );
    });
  }
}

