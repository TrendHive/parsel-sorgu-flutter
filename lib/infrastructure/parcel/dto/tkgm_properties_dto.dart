import 'package:json_annotation/json_annotation.dart';
import 'package:parcel_atlas/core/base/base_dto.dart';

part 'tkgm_properties_dto.g.dart';

/// The `properties` of a registry answer, as the registry spells them.
///
/// Every field is nullable and read through [TkgmPropertiesDTO.text] /
/// [TkgmPropertiesDTO.number]: a public service that drops a field or sends a
/// number as a string must not make a lookup fail — the mapper decides what is
/// required. [raw] keeps the whole map verbatim.
@JsonSerializable(createToJson: false)
final class TkgmPropertiesDTO extends BaseDTO {
  TkgmPropertiesDTO({
    this.ilId,
    this.ilAd,
    this.ilceId,
    this.ilceAd,
    this.mahalleId,
    this.mahalleAd,
    this.adaNo,
    this.parselNo,
    this.pafta,
    this.alan,
    this.nitelik,
    this.mevkii,
    this.zeminKmdurum,
    this.durum,
    this.ozet,
    this.raw = const <String, String>{},
  });

  factory TkgmPropertiesDTO.fromJson(Map<String, dynamic> json) =>
      _$TkgmPropertiesDTOFromJson(json)
        ..raw = <String, String>{
          for (final MapEntry<String, dynamic> entry in json.entries)
            entry.key: '${entry.value ?? ''}',
        };

  @JsonKey(fromJson: number)
  final int? ilId;
  @JsonKey(fromJson: text)
  final String? ilAd;
  @JsonKey(fromJson: number)
  final int? ilceId;
  @JsonKey(fromJson: text)
  final String? ilceAd;
  @JsonKey(fromJson: number)
  final int? mahalleId;
  @JsonKey(fromJson: text)
  final String? mahalleAd;
  @JsonKey(fromJson: text)
  final String? adaNo;
  @JsonKey(fromJson: text)
  final String? parselNo;
  @JsonKey(fromJson: text)
  final String? pafta;
  @JsonKey(fromJson: text)
  final String? alan;
  @JsonKey(fromJson: text)
  final String? nitelik;
  @JsonKey(fromJson: text)
  final String? mevkii;
  @JsonKey(fromJson: text)
  final String? zeminKmdurum;
  @JsonKey(fromJson: text)
  final String? durum;
  @JsonKey(fromJson: text)
  final String? ozet;

  @JsonKey(includeFromJson: false)
  Map<String, String> raw;

  static String? text(Object? value) => value?.toString();

  static int? number(Object? value) =>
      value is int ? value : int.tryParse('${value ?? ''}');
}
