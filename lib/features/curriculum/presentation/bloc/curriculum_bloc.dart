import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/curriculum_repository.dart';

abstract class CurriculumEvent {}

class LoadLanguagesEvent extends CurriculumEvent {}

class LoadUnitsEvent extends CurriculumEvent {
  final String languageId;
  LoadUnitsEvent(this.languageId);
}

class LoadLessonsEvent extends CurriculumEvent {
  final String unitId;
  LoadLessonsEvent(this.unitId);
}

abstract class CurriculumState {}

class CurriculumInitial extends CurriculumState {}
class CurriculumLoading extends CurriculumState {}

class LanguagesLoaded extends CurriculumState {
  final List<dynamic> languages;
  LanguagesLoaded(this.languages);
}

class UnitsLoaded extends CurriculumState {
  final List<dynamic> units;
  UnitsLoaded(this.units);
}

class LessonsLoaded extends CurriculumState {
  final List<dynamic> lessons;
  LessonsLoaded(this.lessons);
}

class CurriculumError extends CurriculumState {
  final String message;
  CurriculumError(this.message);
}

class CurriculumBloc extends Bloc<CurriculumEvent, CurriculumState> {
  final CurriculumRepository repository;

  CurriculumBloc({required this.repository}) : super(CurriculumInitial()) {
    on<LoadLanguagesEvent>((event, emit) async {
      emit(CurriculumLoading());
      final result = await repository.getLanguages();
      result.fold(
        (failure) => emit(CurriculumError(failure.message)),
        (languages) => emit(LanguagesLoaded(languages)),
      );
    });

    on<LoadUnitsEvent>((event, emit) async {
      emit(CurriculumLoading());
      final result = await repository.getUnits(event.languageId);
      result.fold(
        (failure) => emit(CurriculumError(failure.message)),
        (units) => emit(UnitsLoaded(units)),
      );
    });

    on<LoadLessonsEvent>((event, emit) async {
      emit(CurriculumLoading());
      final result = await repository.getLessons(event.unitId);
      result.fold(
        (failure) => emit(CurriculumError(failure.message)),
        (lessons) => emit(LessonsLoaded(lessons)),
      );
    });
  }
}
