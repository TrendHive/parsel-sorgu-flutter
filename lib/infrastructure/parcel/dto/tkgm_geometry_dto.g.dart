// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tkgm_geometry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TkgmGeometryDTO _$TkgmGeometryDTOFromJson(Map<String, dynamic> json) =>
    TkgmGeometryDTO(
      type: json['type'] as String?,
      coordinates:
          (json['coordinates'] as List<dynamic>?)
              ?.map(
                (e) => (e as List<dynamic>)
                    .map(
                      (e) => (e as List<dynamic>).map((e) => e as num).toList(),
                    )
                    .toList(),
              )
              .toList() ??
          const <List<List<num>>>[],
    );
