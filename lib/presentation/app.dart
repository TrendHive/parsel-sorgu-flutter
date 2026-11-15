import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:parcel_atlas/application/auth/cubit/session_cubit.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/l10n/app_localizations.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_local_keys.dart';
import 'package:parcel_atlas/presentation/domain_ui/values/parcel_info_theme.dart';
import 'package:parcel_atlas/presentation/router/parcel_info_router.dart';

/// The app shell: theme, language and routes.
///
/// The [session] decides every page through the router, so it is built
/// once in `main` and handed in. The title users see is Turkish, from the
/// language file.
class App extends StatefulWidget {
  const App({super.key, required this.session});

  final SessionCubit session;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final ParcelInfoRouter _router = ParcelInfoRouter(widget.session);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>.value(
      value: widget.session,
      child: MaterialApp.router(
        routerConfig: _router.router,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: ParcelInfoLocalKeys.localizationsDelegates,
        supportedLocales: ParcelInfoLocalKeys.supportedLocales,
        locale: ParcelInfoLocalKeys.defaultLocale,
        theme: ParcelInfoTheme.lightTheme,
        darkTheme: ParcelInfoTheme.darkTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
