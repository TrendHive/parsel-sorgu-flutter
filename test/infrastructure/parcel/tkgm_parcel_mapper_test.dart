import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/core/base/base_exception.dart';
import 'package:parcel_atlas/core/exception/not_found_exception.dart';
import 'package:parcel_atlas/domain/parcel/value_object/registry_record_value_object.dart';
import 'package:parcel_atlas/infrastructure/parcel/dto/tkgm_parcel_dto.dart';
import 'package:parcel_atlas/infrastructure/parcel/mapper/tkgm_parcel_mapper.dart';

void main() {
  const TkgmParcelMapper mapper = TkgmParcelMapper();

  Map<String, dynamic> fixture() => jsonDecode(
    File('test/support/fixtures/tkgm_parcel_duzkoy_114_1.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;

  test('a registry answer becomes a record keyed by its parcel number', () {
    final Either<BaseException, RegistryRecordValueObject> result = mapper
        .toRecord(TkgmParcelDTO.fromJson(fixture()));
    final RegistryRecordValueObject record = result.right;
    expect(record.key, '130241-114-1');
    expect(record.label, '114/1');
    expect(record.registryAreaSquareMeters, 165.22);
    expect(record.isActive, isTrue);
    expect(record.outline.corners, hasLength(10));
    expect(record.outline.corners.first.latitude, 40.55876);
    expect(record.attributes['ozet'], isNotEmpty);
  });

  test('the registry writes areas the Turkish way', () {
    expect(TkgmParcelMapper.registryArea('98.199,20'), 98199.2);
    expect(TkgmParcelMapper.registryArea('165,22'), 165.22);
    expect(TkgmParcelMapper.registryArea(null), isNull);
  });

  test('an answer without a parcel number is "no parcel here"', () {
    final Map<String, dynamic> json = fixture();
    (json['properties'] as Map<String, dynamic>).remove('parselNo');
    final Either<BaseException, RegistryRecordValueObject> result = mapper
        .toRecord(TkgmParcelDTO.fromJson(json));
    expect(result.left, isA<NotFoundException>());
  });
}
