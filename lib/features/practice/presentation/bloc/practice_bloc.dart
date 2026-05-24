import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/practice_repository.dart';

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

class SubmitAttemptEvent extends PracticeEvent {
  final String attemptId;
  final List<Map<String, dynamic>> answers;
  SubmitAttemptEvent(this.attemptId, this.answers);
}

abstract class PracticeState {}

class PracticeInitial extends PracticeState {}
class PracticeLoading extends PracticeState {}

class RuntimeLoaded extends PracticeState {
  final Map<String, dynamic> runtime;
  RuntimeLoaded(this.runtime);
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

class PracticeError extends PracticeState {
  final String message;
  PracticeError(this.message);
}

class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final PracticeRepository repository;

  PracticeBloc({required this.repository}) : super(PracticeInitial()) {
    on<GetRuntimeEvent>((event, emit) async {
      emit(PracticeLoading());
      final result = await repository.getLessonRuntime(event.lessonId);
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (runtime) => emit(RuntimeLoaded(runtime)),
      );
    });

    on<StartAttemptEvent>((event, emit) async {
      emit(PracticeLoading());
      final result = await repository.startLessonAttempt(event.lessonId);
      result.fold(
        (failure) => emit(PracticeError(failure.message)),
        (attempt) => emit(AttemptStarted(attempt.id, event.exercises)),
      );
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
