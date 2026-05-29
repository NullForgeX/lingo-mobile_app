import 'package:flutter_bloc/flutter_bloc.dart';
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

      emit(RuntimeLoaded(lesson!, runtime!));
    });

    on<StartAttemptEvent>((event, emit) async {
      emit(PracticeLoading());
      final result = await repository.startLessonAttempt(event.lessonId);
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (attempt) => emit(AttemptStarted(attempt.id, event.exercises)),
      );
    });

    on<StartExerciseAttemptEvent>((event, emit) async {
      emit(PracticeLoading());
      final result = await repository.startExerciseAttempt(event.exerciseId);
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (attempt) => emit(AttemptStarted(attempt.id, [event.exercise])),
      );
    });

    on<ListAttemptsEvent>((event, emit) async {
      emit(PracticeLoading());
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
      final result = await repository.submitAttempt(event.attemptId, event.answers);
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (submitResult) => emit(AttemptSubmitted(submitResult)),
      );
    });
  }
}
