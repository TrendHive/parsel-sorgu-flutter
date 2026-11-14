import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:parcel_atlas/application/auth/cubit/session_cubit.dart';

/// Wakes the router whenever the session changes, so its redirect runs
/// again — signing out anywhere lands on sign-in at once.
class SessionRefreshListenable extends ChangeNotifier {
  SessionRefreshListenable(SessionCubit session) {
    _subscription = session.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<SessionState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
