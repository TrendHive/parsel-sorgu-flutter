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
final class ActivityReady extends ActivityState {
  const ActivityReady(this.entries);

  final List<ActivityEntity> entries;
}
