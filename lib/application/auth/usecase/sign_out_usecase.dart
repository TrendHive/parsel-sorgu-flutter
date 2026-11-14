import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';

/// Signs the member out on this device; the router then shows sign-in.
final class SignOutUseCase {
  const SignOutUseCase(this._auth);

  final AuthRepositoryInterface _auth;

  Future<void> call() => _auth.signOut();
}
