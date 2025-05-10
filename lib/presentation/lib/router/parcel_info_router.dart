import 'package:application/home_cubit/home_cubit.dart';
import 'package:core/constants.dart';
import 'package:core/navigation/navigation_service.dart';
import 'package:domain/package/model/package_model.dart';
import 'package:domain/parcel_info/model/parcel_info_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:presentation/home/home_page.dart';
import 'package:presentation/router/route_path.dart';
import 'package:presentation/splash/splash_page.dart';

class ParcelInfoRouter {
  final Function(Locale) onLanguageChange;
  final VoidCallback onThemeToggle;

  ParcelInfoRouter({
    required this.onLanguageChange,
    required this.onThemeToggle,
  });

  late GoRouter router;

  GoRouter getRouter() => GoRouter(
        navigatorKey: NavigationService.navigatorKey,
        routes: getRoutes(),
      );

  static RoutePath path = RoutePath(pathEnd: CoreConstants.empty);

  static RoutePath homePath = RoutePath(pathEnd: "home");

  HomeCubit? homeCubit;

  HomeCubit getHomeCubit() {
    HomeCubit newHomeCubit = HomeCubit();
    newHomeCubit.packageModel = homeCubit?.packageModel ?? PackageModel();
    newHomeCubit.parcelInfoListModel =
        homeCubit?.parcelInfoListModel ?? ParcelInfoListModel();
    homeCubit = newHomeCubit;
    return homeCubit ?? HomeCubit();
  }

  List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: path.pathEnd(),
        builder: (context, state) => BlocProvider(
          create: (context) => getHomeCubit()..getPackageInfo(),
          child: SplashPage(onThemeToggle: onThemeToggle),
        ),
      ),
      GoRoute(
        path: homePath.pathEnd(),
        builder: (context, state) => BlocProvider(
          create: (context) => getHomeCubit(),
          child: const HomePage(),
        ),
      ),
    ];
  }
}
