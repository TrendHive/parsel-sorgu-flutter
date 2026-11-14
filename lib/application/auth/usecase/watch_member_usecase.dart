import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';

/// Who is signed in, as it changes — `null` while nobody is.
final class WatchMemberUseCase {
  const WatchMemberUseCase(this._auth);

  final AuthRepositoryInterface _auth;

  Stream<MemberEntity?> call() => _auth.watchMember();
}
