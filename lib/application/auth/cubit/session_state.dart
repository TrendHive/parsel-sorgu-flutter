part of 'session_cubit.dart';

/// Whether anyone is signed in on this device.
sealed class SessionState {
  const SessionState();
}

/// The stored sign-in is still being restored — show nothing yet.
final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

/// Nobody is signed in: only the sign-in page is reachable.
final class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}

/// A family member is signed in.
final class SessionSignedIn extends SessionState {
  const SessionSignedIn(this.member);

  final MemberEntity member;
}
