import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parcel_atlas/application/auth/usecase/sign_in_usecase.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';

part 'sign_in_state.dart';

/// The sign-in form. Success needs no navigation of its own: the session
/// changes and the router moves to the map.
final class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._signIn) : super(const SignInEditing());

  final SignInUseCase _signIn;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    emit(const SignInSubmitting());
    final Either<BaseException, MemberEntity> result = await _signIn(
      username: username,
      password: password,
    );
    if (isClosed) return;
    switch (result) {
      case Left(:final BaseException value):
        emit(SignInFailed(value));
      case Right():
        emit(const SignInEditing());
    }
  }
}
