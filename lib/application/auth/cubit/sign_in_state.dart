part of 'sign_in_cubit.dart';

/// What the sign-in form is doing.
sealed class SignInState {
  const SignInState();
}

/// Waiting for a username and password.
final class SignInEditing extends SignInState {
  const SignInEditing();
}

/// Checking them.
final class SignInSubmitting extends SignInState {
  const SignInSubmitting();
}

/// They were refused — [exception] says why.
final class SignInFailed extends SignInState {
  const SignInFailed(this.exception);

  final BaseException exception;
}
