import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:parcel_atlas/application/activity/cubit/activity_cubit.dart';
import 'package:parcel_atlas/application/activity/usecase/watch_activity_usecase.dart';
import 'package:parcel_atlas/application/auth/cubit/session_cubit.dart';
import 'package:parcel_atlas/application/auth/cubit/sign_in_cubit.dart';
import 'package:parcel_atlas/application/auth/usecase/sign_in_usecase.dart';
import 'package:parcel_atlas/application/auth/usecase/sign_out_usecase.dart';
import 'package:parcel_atlas/application/auth/usecase/watch_member_usecase.dart';
import 'package:parcel_atlas/application/di/injection.dart';
import 'package:parcel_atlas/application/drawing/usecase/delete_drawing_usecase.dart';
import 'package:parcel_atlas/application/drawing/usecase/save_drawing_usecase.dart';
import 'package:parcel_atlas/application/map/cubit/map_cubit.dart';
import 'package:parcel_atlas/application/map/usecase/locate_device_usecase.dart';
import 'package:parcel_atlas/application/map/usecase/watch_map_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/query_parcel_at_usecase.dart';
import 'package:parcel_atlas/application/parcel/usecase/refresh_parcel_usecase.dart';
import 'package:parcel_atlas/application/person/cubit/holdings_cubit.dart';
import 'package:parcel_atlas/application/person/cubit/persons_cubit.dart';
import 'package:parcel_atlas/application/person/usecase/delete_person_usecase.dart';
import 'package:parcel_atlas/application/person/usecase/save_person_usecase.dart';
import 'package:parcel_atlas/domain/activity/interface/activity_repository_interface.dart';
import 'package:parcel_atlas/domain/auth/interface/auth_repository_interface.dart';
import 'package:parcel_atlas/domain/drawing/interface/drawn_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/map/interface/device_location_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/official_parcel_repository_interface.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/person/interface/person_repository_interface.dart';
import 'package:parcel_atlas/firebase_options.dart';
import 'package:parcel_atlas/infrastructure/activity/repository/activity_repository.dart';
import 'package:parcel_atlas/infrastructure/auth/repository/firebase_auth_repository.dart';
import 'package:parcel_atlas/infrastructure/drawing/repository/drawn_parcel_repository.dart';
import 'package:parcel_atlas/infrastructure/location/location_manager.dart';
import 'package:parcel_atlas/infrastructure/location/service/device_location_service.dart';
import 'package:parcel_atlas/infrastructure/network/dio_client.dart';
import 'package:parcel_atlas/infrastructure/parcel/repository/official_parcel_repository.dart';
import 'package:parcel_atlas/infrastructure/parcel/service/tkgm_parcel_service.dart';
import 'package:parcel_atlas/infrastructure/person/repository/person_repository.dart';
import 'package:parcel_atlas/infrastructure/store/service/firestore_store_service.dart';
import 'package:parcel_atlas/presentation/app.dart';

/// The entry point, and the composition root — the only file that sees
/// every layer.
///
/// Firebase starts first; the store keeps an offline copy, so the map opens
/// with the family's parcels even before the network answers. Then the two
/// sources are built — the internal store and the external registry — the
/// repositories on top of them are registered against the domain's ports,
/// and the use cases and Cubits on top of those. The session is a singleton
/// because the router follows it for the app's whole life; every page Cubit
/// is a factory, made fresh for its page.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final FirebaseFirestore firestore = FirebaseFirestore.instance
    ..settings = const Settings(persistenceEnabled: true);
  _register(firestore, FirebaseAuth.instance);
  runApp(App(session: getIt<SessionCubit>()));
}

void _register(FirebaseFirestore firestore, FirebaseAuth auth) {
  final FirestoreStoreService store = FirestoreStoreService(firestore);
  getIt
    ..registerSingleton<FirestoreStoreService>(store)
    ..registerSingleton<ParcelRegistryInterface>(TkgmParcelService(DioClient()))
    ..registerSingleton<DeviceLocationInterface>(
      DeviceLocationService(LocationManager()),
    )
    ..registerSingleton<AuthRepositoryInterface>(
      FirebaseAuthRepository(auth, store),
    )
    ..registerSingleton<OfficialParcelRepositoryInterface>(
      OfficialParcelRepository(store),
    )
    ..registerSingleton<DrawnParcelRepositoryInterface>(
      DrawnParcelRepository(store),
    )
    ..registerSingleton<PersonRepositoryInterface>(PersonRepository(store))
    ..registerSingleton<ActivityRepositoryInterface>(ActivityRepository(store))
    ..registerFactory(() => SignInUseCase(getIt()))
    ..registerFactory(() => SignOutUseCase(getIt()))
    ..registerFactory(() => WatchMemberUseCase(getIt()))
    ..registerFactory(() => WatchMapUseCase(getIt(), getIt(), getIt()))
    ..registerFactory(() => LocateDeviceUseCase(getIt()))
    ..registerFactory(() => QueryParcelAtUseCase(getIt(), getIt(), getIt()))
    ..registerFactory(() => RefreshParcelUseCase(getIt(), getIt(), getIt()))
    ..registerFactory(() => SaveDrawingUseCase(getIt(), getIt()))
    ..registerFactory(() => DeleteDrawingUseCase(getIt(), getIt()))
    ..registerFactory(() => SavePersonUseCase(getIt(), getIt()))
    ..registerFactory(() => DeletePersonUseCase(getIt(), getIt()))
    ..registerFactory(() => WatchActivityUseCase(getIt()))
    ..registerLazySingleton(() => SessionCubit(getIt(), getIt()))
    ..registerFactory(() => SignInCubit(getIt()))
    ..registerFactory(
      () => MapCubit(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ),
    )
    ..registerFactory(() => PersonsCubit(getIt(), getIt(), getIt(), getIt()))
    ..registerFactory(() => HoldingsCubit(getIt()))
    ..registerFactory(() => ActivityCubit(getIt()));
}
