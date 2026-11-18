part of 'activity_cubit.dart';

/// What the change-log page is showing.
sealed class ActivityState {
  const ActivityState();
}

/// The log has not answered yet.
final class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

/// The log could not be read.
final class ActivityFailed extends ActivityState {
  const ActivityFailed(this.exception);

  final BaseException exception;
}

/// The latest changes, newest first.
///
/// [exception] is the last refused undo and [undone] whether the last one
/// worked; [undoing] is true while one runs, so no second one starts;
/// [messageId] changes with each, so the page shows every message
/// once.
final class ActivityReady extends ActivityState {
  const ActivityReady(
    this.entries, {
    this.exception,
    this.undone = false,
    this.undoing = false,
    this.messageId = CoreConstants.zero,
  });

  final List<ActivityEntity> entries;

  final BaseException? exception;

  final bool undone;

  final bool undoing;

  final int messageId;

  ActivityReady withEntries(List<ActivityEntity> next) =>
      ActivityReady(next, undoing: undoing, messageId: messageId);

  ActivityReady whileUndoing() =>
      ActivityReady(entries, undoing: true, messageId: messageId);

  ActivityReady withResult(Either<BaseException, String> result) =>
      ActivityReady(
        entries,
        exception: result.isLeft ? result.left : null,
        undone: result.isRight,
        messageId: messageId + CoreConstants.one,
      );
}
