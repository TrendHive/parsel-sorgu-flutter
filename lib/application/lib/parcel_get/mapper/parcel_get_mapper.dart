import 'package:core/base/base_mapper.dart';
import 'package:core/constants.dart';
import 'package:domain/parcel_info/model/parcel_info_list_model.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';
import 'package:domain/services/parcel_get/dto/parcel_get_dto_response.dart';
import 'package:domain/services/parcel_info_base/dto/parcel_info_dto.dart';
import 'package:latlong2/latlong.dart';

final class ParcelGetMapper extends BaseMapper<ParcelInfoDTO,
    ParcelGetDTOResponse, ParcelInfoListModel> {
  @override
  ParcelInfoDTO createFromModel(ParcelInfoListModel model) {
    return ParcelInfoDTO();
  }

  @override
  ParcelInfoListModel modelUpdater(
    ParcelInfoListModel model,
    ParcelGetDTOResponse dto,
  ) {
    ParcelInfoModel parcelInfoModel = ParcelInfoModel();
    parcelInfoModel.cityID = dto.properties.ilId;
    parcelInfoModel.cityName = dto.properties.ilAd;
    parcelInfoModel.districtID = dto.properties.ilceId;
    parcelInfoModel.districtName = dto.properties.ilceAd;
    parcelInfoModel.neighborhoodID = dto.properties.mahalleId;
    parcelInfoModel.neighborhoodName = dto.properties.mahalleAd;
    parcelInfoModel.locationString = dto.properties.mevkii;
    parcelInfoModel.status = dto.properties.durum;
    parcelInfoModel.groundStatus = dto.properties.zeminKmdurum;
    parcelInfoModel.parcelID = dto.properties.parselNo;
    parcelInfoModel.summary = dto.properties.ozet;
    parcelInfoModel.blockID = dto.properties.adaNo;
    parcelInfoModel.mapSheetID = dto.properties.pafta;
    parcelInfoModel.kind = dto.properties.nitelik;
    parcelInfoModel.area = double.tryParse(dto.properties.alan
            .replaceAll(CoreConstants.dot, CoreConstants.empty)
            .replaceAll(CoreConstants.comma, CoreConstants.dot)) ??
        CoreConstants.zeroDouble;
    parcelInfoModel.type = dto.geometry.type;
    parcelInfoModel.polygonCoordinates = dto.geometry.coordinates.first
        .map((point) => LatLng(point.last, point.first)) // [lat, lng] = [y, x]
        .toList();
    model.parcelInfoList.add(parcelInfoModel);
    return model;
  }
}
