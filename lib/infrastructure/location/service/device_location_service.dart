import 'package:either_dart/either.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';
import 'package:parcel_atlas/core/exception/unknown_exception.dart';
import 'package:parcel_atlas/domain/map/interface/device_location_interface.dart';
import 'package:parcel_atlas/infrastructure/location/location_manager.dart';

/// The device's position, through the existing [LocationManager].
///
/// [timeout] bounds the wait: a phone indoors can search for a fix forever,
/// and a button that never answers is worse than one that says no.
class DeviceLocationService implements DeviceLocationInterface {
  DeviceLocationService(this._manager);

  final LocationManager _manager;

  static const Duration timeout = Duration(seconds: 10);

  @override
  Future<Either<BaseException, LatLng>> current() async {
    try {
      final Position position = await _manager.determinePosition().timeout(
        timeout,
      );
      return Right(LatLng(position.latitude, position.longitude));
    } catch (e) {
      return Left(UnknownException(cause: UnknownCause(cause: e)));
    }
  }
}
