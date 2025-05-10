import 'dart:math';

import 'package:application/parcel_get/usecase/parcel_get_usecase.dart';
import 'package:core/base/base_exception.dart';
import 'package:domain/constants.dart';
import 'package:domain/package/model/package_model.dart';
import 'package:domain/parcel_info/model/parcel_info_list_model.dart';
import 'package:domain/parcel_info/model/parcel_info_model.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:infrastructure/location/location_manager.dart';
import 'package:infrastructure/utility/package_utils.dart';
import 'package:latlong2/latlong.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  List<BaseException> exceptionList = [];

  PackageModel packageModel = PackageModel();
  ParcelInfoListModel parcelInfoListModel = ParcelInfoListModel();

  ParcelGetUseCase parcelGetUseCase = ParcelGetUseCase();

  Future<void> getPackageInfo() async {
    emit(HomeLoading());
    await PackageUtils().init();
    packageModel.appName = PackageUtils().appName;
    packageModel.packageName = PackageUtils().packageName;
    packageModel.version = PackageUtils().version;
    packageModel.buildNumber = PackageUtils().buildNumber;
    Position position = await LocationManager().determinePosition();
    if (position.latitude >= DomainConstants.turkeyStartLatitude &&
        position.latitude <= DomainConstants.turkeyEndLatitude &&
        position.longitude >= DomainConstants.turkeyStartLongitude &&
        position.longitude <= DomainConstants.turkeyEndLongitude) {
      parcelInfoListModel.location =
          LatLng(position.latitude, position.longitude);
    }
    emit(HomeStart());
    return;
  }

  Future<void> getParcelInfo({required LatLng point}) async {
    emit(HomeLoading());
    parcelInfoListModel.point = point;
    for (ParcelInfoModel parcelInfo in parcelInfoListModel.parcelInfoList) {
      if (isPointInPolygon(point, parcelInfo.polygonCoordinates)) {
        ParcelInfoModel parcelInfoModel = parcelInfo;
        parcelInfoListModel.parcelInfoList.remove(parcelInfo);
        parcelInfoListModel.parcelInfoList.add(parcelInfoModel);
        emit(HomeParcelInfoShow());
        return;
      }
    }
    Either<BaseException, ParcelInfoListModel> result =
        await parcelGetUseCase.execute(parcelInfoListModel);
    result.fold((left) {
      exceptionList.add(result.left);
      emit(HomeError());
    }, (right) {
      emit(HomeParcelInfoFound());
    });
    return;
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng a = polygon[j];
      LatLng b = polygon[j + 1];

      if (rayIntersectsSegment(point, a, b)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2 == 1); // Tekse içeride
  }

  bool rayIntersectsSegment(LatLng point, LatLng a, LatLng b) {
    double px = point.longitude;
    double py = point.latitude;
    double ax = a.longitude;
    double ay = a.latitude;
    double bx = b.longitude;
    double by = b.latitude;

    if (ay > by) {
      double tempX = ax, tempY = ay;
      ax = bx;
      ay = by;
      bx = tempX;
      by = tempY;
    }

    if (py == ay || py == by) py += 0.0000001; // Tam çizgi üstündeyse kaydır

    if (py < ay || py > by) return false;
    if (px >= max(ax, bx)) return false;

    if (px < min(ax, bx)) return true;

    double red = (ax != bx) ? ((by - ay) / (bx - ax)) : double.infinity;
    double blue = (ax != px) ? ((py - ay) / (px - ax)) : double.infinity;

    return blue >= red;
  }
}
