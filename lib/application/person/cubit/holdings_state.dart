part of 'holdings_cubit.dart';

/// What the holdings page is showing.
sealed class HoldingsState {
  const HoldingsState();
}

/// The family's store has not answered yet.
final class HoldingsLoading extends HoldingsState {
  const HoldingsLoading();
}

/// The store could not be read, or the person or group no longer exists.
final class HoldingsFailed extends HoldingsState {
  const HoldingsFailed(this.exception);

  final BaseException exception;
}

/// One holder's parcels with totals.
///
/// [title] is the person's or group's name; [holdings] their parcels;
/// [members] the group's people (empty for a person) and [groups] the
/// person's groups (empty for a group).
final class HoldingsReady extends HoldingsState {
  const HoldingsReady({
    required this.title,
    required this.holdings,
    required this.members,
    required this.groups,
  });

  final String title;

  final HoldingsReadModel holdings;

  final List<PersonEntity> members;

  final List<PersonGroupEntity> groups;
}
