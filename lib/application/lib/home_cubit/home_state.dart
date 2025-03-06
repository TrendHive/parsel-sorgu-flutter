part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeStart extends HomeState {}

final class HomeParcelInfoFound extends HomeState {}

final class HomeError extends HomeState {}
