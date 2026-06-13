import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/home_repository.dart';

abstract class HomeEvent {}

class LoadDashboardEvent extends HomeEvent {}

class LoadLeaderboardEvent extends HomeEvent {
  final int page;
  final int pageSize;
  final String order;
  LoadLeaderboardEvent({this.page = 1, this.pageSize = 20, this.order = 'desc'});
}

abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final Map<String, dynamic> dashboard;
  HomeLoaded(this.dashboard);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class LeaderboardLoading extends HomeState {}

class LeaderboardLoaded extends HomeState {
  final Map<String, dynamic> leaderboardData;
  LeaderboardLoaded(this.leaderboardData);
}

class LeaderboardError extends HomeState {
  final String message;
  LeaderboardError(this.message);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadDashboardEvent>((event, emit) async {
      emit(HomeLoading());
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        final box = Hive.box('guest_dashboard_box');
        final dashboard = Map<String, dynamic>.from(box.get('dashboard', defaultValue: <String, dynamic>{}) as Map);
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
          dashboard['preferredLanguage'] = null;
          await box.put('dashboard', dashboard);
        }
        emit(HomeLoaded(dashboard));
        return;
      }
      
      final result = await repository.getDashboard();
      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (dashboard) => emit(HomeLoaded(dashboard)),
      );
    });

    on<LoadLeaderboardEvent>((event, emit) async {
      emit(LeaderboardLoading());
      final isGuest = Hive.box('auth_preferences_box').get('isGuest', defaultValue: false) as bool;
      if (isGuest) {
        emit(LeaderboardLoaded({
          'items': <dynamic>[],
          'userRank': {'rank': 0, 'xp': 0},
        }));
        return;
      }
      
      final result = await repository.getLeaderboard(
        page: event.page,
        pageSize: event.pageSize,
        order: event.order,
      );
      result.fold(
        (failure) => emit(LeaderboardError(failure.message)),
        (leaderboardData) => emit(LeaderboardLoaded(leaderboardData)),
      );
    });
  }
}

