import 'package:either_dart/either.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/admin_only_cause.dart';
import 'package:parcel_atlas/core/cause/not_signed_in_cause.dart';
import 'package:parcel_atlas/core/exception/auth_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';

/// Removes a drawn boundary — the main account's call only.
final class DeleteDrawingUseCase {
  const DeleteDrawingUseCase(this._auth, this._drawings);

  final AuthRepositoryInterface _auth;

  final DrawnParcelRepositoryInterface _drawings;

  Future<Either<BaseException, String>> call(DrawnParcelEntity drawing) async {
    final MemberEntity? actor = _auth.currentMember;
    if (actor == null) {
      return Left(AuthException(cause: NotSignedInCause()));
    }
    if (!actor.canDelete) {
      return Left(AuthException(cause: AdminOnlyCause()));
    }
    return _drawings.delete(drawing, actor: actor);
  }
}
