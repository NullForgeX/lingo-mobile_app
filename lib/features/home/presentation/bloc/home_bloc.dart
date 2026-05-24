import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/home_repository.dart';

abstract class HomeEvent {}

class LoadDashboardEvent extends HomeEvent {}

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

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadDashboardEvent>((event, emit) async {
      emit(HomeLoading());
      final result = await repository.getDashboard();
      result.fold(
        (failure) => emit(HomeError(failure.message)),
        (dashboard) => emit(HomeLoaded(dashboard)),
      );
    });
  }
}
