import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';

/// The change log, newest first, and undoing a change from it.
///
/// No line is written here on purpose: every repository that changes a
/// record writes its log line in the same atomic batch, so a change without
/// a line — or a line without its change — cannot exist.
///
/// [linesOf] is every line of one change. [latestChangeBy] is the id of the
/// newest change a member made that can be undone, or null. [undo] puts
/// every record of a change back as it was, in one batch that is itself a
/// signed, logged (and undoable) change; it is refused when any of those
/// records was changed again afterwards.
abstract interface class ActivityRepositoryInterface {
  Stream<Either<BaseException, List<ActivityEntity>>> watchRecent(int limit);

  Future<Either<BaseException, List<ActivityEntity>>> linesOf(String changeId);

  Future<Either<BaseException, String?>> latestChangeBy(String memberId);

  Future<Either<BaseException, String>> undo(
    String changeId, {
    required MemberEntity actor,
  });
}
