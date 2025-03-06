// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geometry_dto_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeometryDTOResponse _$GeometryDTOResponseFromJson(Map<String, dynamic> json) =>
    GeometryDTOResponse(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => (e as List<dynamic>)
                  .map((e) => (e as num).toDouble())
                  .toList())
              .toList())
          .toList(),
    );
