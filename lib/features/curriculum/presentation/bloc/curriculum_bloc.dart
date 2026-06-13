import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../../../auth/domain/entities/user.dart';

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

class SelectLanguageEvent extends CurriculumEvent {
  final String languageId;
  SelectLanguageEvent(this.languageId);
}

class LoadLanguageDetailEvent extends CurriculumEvent {
  final String languageId;
  LoadLanguageDetailEvent(this.languageId);
}

class DownloadUnitEvent extends CurriculumEvent {
  final String unitId;
  DownloadUnitEvent(this.unitId);
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
  final List<String> downloadedUnitIds;
  final List<String> downloadingUnitIds;
  final String? error;
  UnitsLoaded(
    this.units, {
    this.downloadedUnitIds = const [],
    this.downloadingUnitIds = const [],
    this.error,
  });
}

class LessonsLoaded extends CurriculumState {
  final List<dynamic> lessons;
  LessonsLoaded(this.lessons);
}

class LanguageSelectedState extends CurriculumState {
  final User user;
  LanguageSelectedState(this.user);
}

class LanguageDetailLoaded extends CurriculumState {
  final Map<String, dynamic> language;
  LanguageDetailLoaded(this.language);
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
      final downloadedResult = await repository.getDownloadedUnits();

      List<String> downloadedUnitIds = [];
      downloadedResult.fold(
        (_) {},
        (ids) => downloadedUnitIds = ids,
      );

      result.fold(
        (failure) => emit(CurriculumError(failure.message)),
        (units) => emit(UnitsLoaded(
          units,
          downloadedUnitIds: downloadedUnitIds,
        )),
      );
    });

    on<DownloadUnitEvent>((event, emit) async {
      final currentState = state;
      if (currentState is UnitsLoaded) {
        final newDownloading = List<String>.from(currentState.downloadingUnitIds);
        if (!newDownloading.contains(event.unitId)) {
          newDownloading.add(event.unitId);
        }

        emit(UnitsLoaded(
          currentState.units,
          downloadedUnitIds: currentState.downloadedUnitIds,
          downloadingUnitIds: newDownloading,
        ));

        final result = await repository.downloadUnit(event.unitId);
        final finalDownloading = List<String>.from(newDownloading)..remove(event.unitId);

        await result.fold(
          (failure) async {
            emit(UnitsLoaded(
              currentState.units,
              downloadedUnitIds: currentState.downloadedUnitIds,
              downloadingUnitIds: finalDownloading,
              error: failure.message,
            ));
            // Emit again immediately to clear the transient error message
            emit(UnitsLoaded(
              currentState.units,
              downloadedUnitIds: currentState.downloadedUnitIds,
              downloadingUnitIds: finalDownloading,
            ));
          },
          (_) async {
            final newDownloaded = List<String>.from(currentState.downloadedUnitIds);
            if (!newDownloaded.contains(event.unitId)) {
              newDownloaded.add(event.unitId);
            }
            emit(UnitsLoaded(
              currentState.units,
              downloadedUnitIds: newDownloaded,
              downloadingUnitIds: finalDownloading,
            ));
          },
        );
      }
    });

    on<LoadLessonsEvent>((event, emit) async {
      emit(CurriculumLoading());
      final result = await repository.getLessons(event.unitId);
      result.fold(
        (failure) => emit(CurriculumError(failure.message)),
        (lessons) => emit(LessonsLoaded(lessons)),
      );
    });

    on<SelectLanguageEvent>((event, emit) async {
      emit(CurriculumLoading());
      final authBox = Hive.box('auth_preferences_box');
      final isGuest = authBox.get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        final result = await repository.getLanguageDetail(event.languageId);
        await result.fold(
          (failure) async => emit(CurriculumError(failure.message)),
          (langDetail) async {
            final dashboardBox = Hive.box('guest_dashboard_box');
            final dashboard = Map<String, dynamic>.from(
                dashboardBox.get('dashboard', defaultValue: <String, dynamic>{}) as Map);
            dashboard['preferredLanguage'] = {
              'id': event.languageId,
              'name': langDetail['name'],
              'nativeName': langDetail['nativeName'],
              'script': langDetail['script'],
              'summary': langDetail['summary'],
            };
            await dashboardBox.put('dashboard', dashboard);

            final mockGuestUser = User(
              id: 'guest',
              email: 'guest@lingo.com',
              displayName: 'Guest',
              role: 'learner',
              status: 'active',
              preferredLanguageId: event.languageId,
            );
            emit(LanguageSelectedState(mockGuestUser));
          },
        );
      } else {
        final result = await repository.selectLanguage(event.languageId);
        result.fold(
          (failure) => emit(CurriculumError(failure.message)),
          (user) => emit(LanguageSelectedState(user)),
        );
      }
    });

    on<LoadLanguageDetailEvent>((event, emit) async {
      emit(CurriculumLoading());
      final result = await repository.getLanguageDetail(event.languageId);
      result.fold(
        (failure) => emit(CurriculumError(failure.message)),
        (language) => emit(LanguageDetailLoaded(language)),
      );
    });
  }
}
