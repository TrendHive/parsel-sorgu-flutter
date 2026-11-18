import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/admin_only_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/cause/nothing_to_undo_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/core/exception/validation_exception.dart';
import 'package:parcel_atlas/domain/activity/entity/activity_entity.dart';
import 'package:parcel_atlas/domain/activity/enum/activity_action_enum.dart';
import 'package:parcel_atlas/domain/activity/interface/activity_repository_interface.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';

/// Undoes one saved change — `changeId`, or when it is null the newest
/// change the signed-in member made.
///
/// Every line of the change must remember its record, or nothing is undone.
/// Undoing a change that created records deletes them, and only the main
/// account may delete, so such a change is the main account's to undo.
/// Answers the change id of the undo itself.
final class UndoChangeUseCase {
  const UndoChangeUseCase(this._auth, this._activity);

  final AuthRepositoryInterface _auth;

  final ActivityRepositoryInterface _activity;

  Future<Either<BaseException, String>> call({String? changeId}) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    final String? id;
    if (changeId != null) {
      id = changeId;
    } else {
      final Either<BaseException, String?> latest = await _activity
          .latestChangeBy(actor.id);
      if (latest.isLeft) return Left(latest.left);
      id = latest.right;
    }
    if (id == null) {
      return Left(ValidationException(cause: NothingToUndoCause()));
    }
    final Either<BaseException, List<ActivityEntity>> lines = await _activity
        .linesOf(id);
    if (lines.isLeft) return Left(lines.left);
    if (lines.right.isEmpty ||
        lines.right.any((ActivityEntity line) => !line.canUndo)) {
      return Left(ValidationException(cause: NothingToUndoCause()));
    }
    if (!actor.canDelete &&
        lines.right.any(
          (ActivityEntity line) => line.action == ActivityActionEnum.created,
        )) {
      return Left(AuthException(cause: AdminOnlyCause()));
    }
    return _activity.undo(id, actor: actor);
  }
}
