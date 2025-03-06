import 'package:core/base/base_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'properties_dto_response.g.dart';

@JsonSerializable(createToJson: false)
final class PropertiesDTOResponse extends BaseDTO {
  @JsonKey(name: 'ilceAd')
  final String ilceAd;
  @JsonKey(name: 'mevkii')
  final String mevkii;
  @JsonKey(name: 'ilId')
  final int ilId;
  @JsonKey(name: 'durum')
  final String durum;
  @JsonKey(name: 'ilceId')
  final int ilceId;
  @JsonKey(name: 'zeminKmdurum')
  final String zeminKmdurum;
  @JsonKey(name: 'parselNo')
  final String parselNo;
  @JsonKey(name: 'mahalleAd')
  final String mahalleAd;
  @JsonKey(name: 'ozet')
  final String ozet;
  @JsonKey(name: 'gittigiParselListe')
  final String gittigiParselListe;
  @JsonKey(name: 'gittigiParselSebep')
  final String gittigiParselSebep;
  @JsonKey(name: 'alan')
  final String alan;
  @JsonKey(name: 'adaNo')
  final String adaNo;
  @JsonKey(name: 'nitelik')
  final String nitelik;
  @JsonKey(name: 'ilAd')
  final String ilAd;
  @JsonKey(name: 'mahalleId')
  final int mahalleId;
  @JsonKey(name: 'pafta')
  final String pafta;

  PropertiesDTOResponse({
    required this.ilceAd,
    required this.mevkii,
    required this.ilId,
    required this.durum,
    required this.ilceId,
    required this.parselNo,
    required this.zeminKmdurum,
    required this.mahalleAd,
    required this.ozet,
    required this.gittigiParselListe,
    required this.gittigiParselSebep,
    required this.alan,
    required this.adaNo,
    required this.nitelik,
    required this.ilAd,
    required this.mahalleId,
    required this.pafta,
  });

  factory PropertiesDTOResponse.fromJson(dynamic json) =>
      _$PropertiesDTOResponseFromJson(json);
}
