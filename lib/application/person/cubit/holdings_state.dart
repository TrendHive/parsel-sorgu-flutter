part of 'holdings_cubit.dart';

/// What the holdings page is showing.
sealed class HoldingsState {
  const HoldingsState();
}

/// The family's store has not answered yet.
final class HoldingsLoading extends HoldingsState {
  const HoldingsLoading();
}

/// The store could not be read, or the person no longer exists.
final class HoldingsFailed extends HoldingsState {
  const HoldingsFailed(this.exception);

  final BaseException exception;
}

/// One person's parcels with totals.
///
/// [person] is whose page it is; [holdings] what reaches them; [parent]
/// their parent in the tree, if any; [spouse] their husband or wife, if
/// any; and [children] the couple's children, recorded under either of them.
/// [passedOn] is whether their shares have gone on to those children.
final class HoldingsReady extends HoldingsState {
  const HoldingsReady({
    required this.person,
    required this.holdings,
    required this.parent,
    required this.spouse,
    required this.children,
    required this.passedOn,
  });

  final PersonEntity person;

  final HoldingsReadModel holdings;

  final PersonEntity? parent;

  final PersonEntity? spouse;

  final List<PersonEntity> children;

  final bool passedOn;
}
