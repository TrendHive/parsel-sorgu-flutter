import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';

/// Where this device is, for the map's "my location" button.
///
/// Optional by nature: a refused permission or a desktop without a fix is a
/// `Left`, and the map simply stays where it is.
abstract interface class DeviceLocationInterface {
  Future<Either<BaseException, LatLng>> current();
}
