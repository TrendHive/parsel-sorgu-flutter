part of 'persons_cubit.dart';

/// What the people page is showing.
sealed class PersonsState {
  const PersonsState();
}

/// The family's store has not answered yet.
final class PersonsLoading extends PersonsState {
  const PersonsLoading();
}

/// The store could not be read.
final class PersonsFailed extends PersonsState {
  const PersonsFailed(this.exception);

  final BaseException exception;
}

/// The family tree, with what reaches each person.
///
/// [snapshot] answers every holdings question; [member] decides whether
/// delete buttons show. [exception] is the last refused change, [saved] the
/// last one that worked; [messageId] changes with each, so the page shows
/// every message once.
final class PersonsReady extends PersonsState {
  const PersonsReady({
    required this.snapshot,
    required this.member,
    this.exception,
    this.saved = false,
    this.messageId = CoreConstants.zero,
  });

  final MapSnapshotReadModel snapshot;

  final MemberEntity? member;

  final BaseException? exception;

  final bool saved;

  final int messageId;

  PersonsReady withSnapshot(MapSnapshotReadModel next) =>
      PersonsReady(snapshot: next, member: member, messageId: messageId);

  PersonsReady withResult(Either<BaseException, String> result) => PersonsReady(
    snapshot: snapshot,
    member: member,
    exception: result.isLeft ? result.left : null,
    saved: result.isRight,
    messageId: messageId + CoreConstants.one,
  );
}
