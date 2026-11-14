import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:latlong2/latlong.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/cause/unknown_cause.dart';
import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/core/exception/bad_response_exception.dart';
import 'package:parcel_atlas/core/exception/network_exception.dart';
import 'package:parcel_atlas/core/logger/local_logger.dart';
import 'package:parcel_atlas/domain/parcel/interface/parcel_registry_interface.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/infrastructure/constants.dart';
import 'package:parcel_atlas/infrastructure/network/dio_client.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_parcel_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/mapper/tkgm_parcel_mapper.dart';

/// The external source: the official land registry (TKGM), over HTTP.
///
/// One method per question the registry can answer, each one GET and each
/// one of the connection's few daily lookups — which is why nothing above
/// infrastructure calls it except through a repository that asked the
/// family's store first. Every failure comes back as a [BaseException] the
/// `ErrorInterceptor` already classified (quota, no parcel, network).
///
/// The `ManipulatorInterceptor` wraps every answer in `{"data": ...}`, so the
/// feature is read from there.
class TkgmParcelService implements ParcelRegistryInterface {
  TkgmParcelService(this._client, {TkgmParcelMapper? mapper})
    : _mapper = mapper ?? const TkgmParcelMapper();

  final DioClient _client;

  final TkgmParcelMapper _mapper;

  static const String _envelope = 'data';

  @override
  Future<Either<BaseException, RegistryRecordValueObject>> fetchAt(
    LatLng point,
  ) => _fetch(
    <Object>[
      InfrastructureConstants.parcelAtPoint,
      point.latitude,
      point.longitude,
      CoreConstants.empty,
    ].join(CoreConstants.slash),
  );

  @override
  Future<Either<BaseException, RegistryRecordValueObject>> fetchByNumber({
    required int neighborhoodId,
    required String block,
    required String parcel,
  }) => _fetch(
    <Object>[
      InfrastructureConstants.parcelByNumber,
      neighborhoodId,
      Uri.encodeComponent(block),
      Uri.encodeComponent(parcel),
    ].join(CoreConstants.slash),
  );

  Future<Either<BaseException, RegistryRecordValueObject>> _fetch(
    String path,
  ) async {
    try {
      final Response<dynamic> response = await _client.dio.get<dynamic>(path);
      final Object? body = (response.data as Map<String, dynamic>?)?[_envelope];
      if (body is! Map<String, dynamic>) {
        return Left(BadResponseException(cause: UnknownCause(cause: body)));
      }
      return _mapper.toRecord(TkgmParcelDTO.fromJson(body));
    } on DioException catch (e, stackTrace) {
      LocalLogger.error(e, stackTrace: stackTrace);
      final Object? error = e.error;
      return Left(
        error is BaseException
            ? error
            : NetworkException(cause: UnknownCause(cause: e.message)),
      );
    } catch (e, stackTrace) {
      LocalLogger.error(e, stackTrace: stackTrace);
      return Left(BadResponseException(cause: UnknownCause(cause: e)));
    }
  }
}
