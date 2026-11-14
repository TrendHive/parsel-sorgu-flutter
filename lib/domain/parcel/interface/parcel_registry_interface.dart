import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';

/// The official land registry (TKGM's parcel query service).
///
/// Every call spends one of the connection's daily lookups, so callers ask the
/// family's store first and come here only for a parcel nobody has fetched.
/// [fetchAt] finds the parcel under a point; [fetchByNumber] fetches a known
/// parcel again by neighbourhood, block and parcel number — exact, unlike a
/// point that might fall on a border.
abstract interface class ParcelRegistryInterface {
  Future<Either<BaseException, RegistryRecordValueObject>> fetchAt(
    LatLng point,
  );

  Future<Either<BaseException, RegistryRecordValueObject>> fetchByNumber({
    required int neighborhoodId,
    required String block,
    required String parcel,
  });
}
