part of 'compare_cubit.dart';

/// What the comparison page is showing.
sealed class CompareState {
  const CompareState();
}

/// The family's store has not answered yet.
final class CompareLoading extends CompareState {
  const CompareLoading();
}

/// The store could not be read.
final class CompareFailed extends CompareState {
  const CompareFailed(this.exception);

  final BaseException exception;
}

/// The compared parcels and the owners' totals.
final class CompareReady extends CompareState {
  const CompareReady(this.table);

  final CompareTableReadModel table;
}
