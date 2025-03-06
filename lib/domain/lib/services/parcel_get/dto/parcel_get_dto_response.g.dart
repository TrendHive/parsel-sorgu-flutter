// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_get_dto_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcelGetDTOResponse _$ParcelGetDTOResponseFromJson(
        Map<String, dynamic> json) =>
    ParcelGetDTOResponse(
      type: json['type'] as String,
      geometry: GeometryDTOResponse.fromJson(json['geometry']),
      properties: PropertiesDTOResponse.fromJson(json['properties']),
    );
