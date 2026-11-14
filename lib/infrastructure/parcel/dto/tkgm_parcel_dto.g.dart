// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tkgm_parcel_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TkgmParcelDTO _$TkgmParcelDTOFromJson(Map<String, dynamic> json) =>
    TkgmParcelDTO(
      geometry: json['geometry'] == null
          ? null
          : TkgmGeometryDTO.fromJson(json['geometry'] as Map<String, dynamic>),
      properties: json['properties'] == null
          ? null
          : TkgmPropertiesDTO.fromJson(
              json['properties'] as Map<String, dynamic>,
            ),
    );
