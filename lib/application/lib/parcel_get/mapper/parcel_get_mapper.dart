import 'package:core/base/base_mapper.dart';
import 'package:core/constants.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';
import 'package:domain/services/parcel_get/dto/parcel_get_dto_response.dart';
import 'package:domain/services/parcel_info_base/dto/parcel_info_dto.dart';

final class ParcelGetMapper
    extends BaseMapper<ParcelInfoDTO, ParcelGetDTOResponse, ParcelInfoModel> {
  @override
  ParcelInfoDTO createFromModel(ParcelInfoModel model) {
    return ParcelInfoDTO();
  }

  @override
  ParcelInfoModel modelUpdater(
    ParcelInfoModel model,
    ParcelGetDTOResponse dto,
  ) {
    model.cityID = dto.properties.ilId;
    model.cityName = dto.properties.ilAd;
    model.districtID = dto.properties.ilceId;
    model.districtName = dto.properties.ilceAd;
    model.neighborhoodID = dto.properties.mahalleId;
    model.neighborhoodName = dto.properties.mahalleAd;
    model.locationString = dto.properties.mevkii;
    model.status = dto.properties.durum;
    model.groundStatus = dto.properties.zeminKmdurum;
    model.parcelID = dto.properties.parselNo;
    model.summary = dto.properties.ozet;
    model.blockID = dto.properties.adaNo;
    model.mapSheetID = dto.properties.pafta;
    model.kind = dto.properties.nitelik;
    model.area =
        double.tryParse(dto.properties.alan) ?? CoreConstants.zeroDouble;
    model.type = dto.geometry.type;
    model.coordinates = dto.geometry.coordinates;
    return model;
  }
}
