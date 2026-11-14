import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/map/interface/device_location_interface.dart';

/// Where this device is, for "my location" — useful when standing on a
/// parcel to see which one it is.
class LocateDeviceUseCase {
  const LocateDeviceUseCase(this._location);

  final DeviceLocationInterface _location;

  Future<Either<BaseException, LatLng>> call() => _location.current();
}
