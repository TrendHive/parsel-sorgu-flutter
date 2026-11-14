import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/auth/usecase/sign_out_usecase.dart';
import 'package:parcel_atlas/application/auth/usecase/watch_member_usecase.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';

part 'session_state.dart';

/// Who is signed in, for the whole app — the router decides every page from
/// it, so it lives as long as the app does.
final class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._watchMember, this._signOut)
    : super(const SessionUnknown()) {
    _subscription = _watchMember().listen(
      (MemberEntity? member) => emit(
        member == null ? const SessionSignedOut() : SessionSignedIn(member),
      ),
    );
  }

  final WatchMemberUseCase _watchMember;

  final SignOutUseCase _signOut;

  late final StreamSubscription<MemberEntity?> _subscription;

  Future<void> signOut() => _signOut();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
