import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:parcel_atlas/application/auth/cubit/session_cubit.dart';
import 'package:parcel_atlas/core/navigation/navigation_service.dart';
import 'package:parcel_atlas/presentation/activity/activity_page.dart';
import 'package:parcel_atlas/presentation/holdings/holdings_page.dart';
import 'package:parcel_atlas/presentation/map/map_page.dart';
import 'package:parcel_atlas/presentation/people/people_page.dart';
import 'package:parcel_atlas/presentation/router/route_path.dart';
import 'package:parcel_atlas/presentation/router/session_refresh_listenable.dart';
import 'package:parcel_atlas/presentation/sign_in/sign_in_page.dart';
import 'package:parcel_atlas/presentation/splash/splash_page.dart';

/// Every address in the app, and the rule that picks one.
///
/// The session decides: while it is restoring, only [splash]; signed out,
/// only [signIn]; signed in, everything but those two. The router listens
/// to the session, so signing out anywhere lands on sign-in at once.
///
/// [map] takes an optional `focus` query — a record id to select and frame,
/// which is how the holdings page's "show on map" works. [holdings] is one
/// person's parcels.
class ParcelInfoRouter {
  ParcelInfoRouter(this._session)
    : _refresh = SessionRefreshListenable(_session) {
    router = GoRouter(
      navigatorKey: NavigationService.navigatorKey,
      initialLocation: map.path(),
      refreshListenable: _refresh,
      redirect: _redirect,
      routes: <RouteBase>[
        GoRoute(
          path: splash.pathEnd(),
          builder: (BuildContext context, GoRouterState state) =>
              const SplashPage(),
        ),
        GoRoute(
          path: signIn.pathEnd(),
          builder: (BuildContext context, GoRouterState state) =>
              const SignInPage(),
        ),
        GoRoute(
          path: map.pathEnd(),
          builder: (BuildContext context, GoRouterState state) =>
              MapPage(focusId: state.uri.queryParameters[focusQuery]),
        ),
        GoRoute(
          path: people.pathEnd(),
          builder: (BuildContext context, GoRouterState state) =>
              const PeoplePage(),
          routes: <RouteBase>[
            GoRoute(
              path: holdings.pathEnd(),
              builder: (BuildContext context, GoRouterState state) =>
                  HoldingsPage(
                    personId: state.pathParameters[holdings.parameter()]!,
                  ),
            ),
          ],
        ),
        GoRoute(
          path: activity.pathEnd(),
          builder: (BuildContext context, GoRouterState state) =>
              const ActivityPage(),
        ),
      ],
    );
  }

  final SessionCubit _session;

  final SessionRefreshListenable _refresh;

  late final GoRouter router;

  static const String focusQuery = 'focus';

  static final RoutePath splash = RoutePath(pathEnd: 'loading');
  static final RoutePath signIn = RoutePath(pathEnd: 'sign-in');
  static final RoutePath map = RoutePath(pathEnd: 'map');
  static final RoutePath people = RoutePath(pathEnd: 'people');
  static final RoutePath holdings = RoutePath(
    path: people,
    pathEnd: 'person',
    parameter: 'personId',
  );
  static final RoutePath activity = RoutePath(pathEnd: 'activity');

  static String holdingsOf(String personId) =>
      holdings.path(parameter: personId);

  static String mapFocused(String id) => Uri(
    path: map.path(),
    queryParameters: <String, String>{focusQuery: id},
  ).toString();

  String? _redirect(BuildContext context, GoRouterState state) {
    final String location = state.matchedLocation;
    return switch (_session.state) {
      SessionUnknown() => location == splash.path() ? null : splash.path(),
      SessionSignedOut() => location == signIn.path() ? null : signIn.path(),
      SessionSignedIn() =>
        location == signIn.path() || location == splash.path()
            ? map.path()
            : null,
    };
  }

  void dispose() {
    _refresh.dispose();
    router.dispose();
  }
}
