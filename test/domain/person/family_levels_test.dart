import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/domain/drawing/entity/drawn_parcel_entity.dart';
import 'package:parcel_atlas/domain/map/read_model/map_snapshot_read_model.dart';
import 'package:parcel_atlas/domain/parcel/entity/official_parcel_entity.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/ownership_value_object.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../../support/fakes.dart';

OwnershipValueObject _whole(String id) =>
    OwnershipValueObject(personId: id, share: ShareValueObject.whole);

void main() {
  test('the tree knows how deep each person and the family is', () {
    expect(FamilyRules.depthOf(testFamily, 'grandfather'), 0);
    expect(FamilyRules.depthOf(testFamily, 'uncle'), 1);
    expect(FamilyRules.depthOf(testFamily, 'c'), 2);
    expect(FamilyRules.generations(testFamily), 3);
  });

  test('land recorded on a grandson belongs to his father\'s branch', () {
    expect(FamilyRules.holdersAt(testFamily, 'c', 1), <String>{'father'});
    expect(FamilyRules.holdersAt(testFamily, 'c', 0), <String>{'grandfather'});
  });

  test('land recorded on the grandfather reaches both branches below', () {
    expect(FamilyRules.holdersAt(testFamily, 'grandfather', 1), <String>{
      'father',
      'uncle',
    });
    expect(FamilyRules.holdersAt(testFamily, 'father', 2), <String>{
      'a',
      'b',
      'c',
      'd',
    });
  });

  test('land of someone whose share did not pass on stays theirs', () {
    expect(FamilyRules.holdersAt(testFamily, 'uncle', 2), <String>{'uncle'});
  });

  test('the legend lists the branches that hold something at a level', () {
    final MapSnapshotReadModel snapshot = MapSnapshotReadModel(
      officials: const <OfficialParcelEntity>[],
      drawings: <DrawnParcelEntity>[
        testDrawing('one', <OwnershipValueObject>[_whole('a')]),
        testDrawing('two', <OwnershipValueObject>[_whole('uncle')]),
      ],
      persons: testFamily,
    );

    expect(snapshot.branchesAt(1).map((PersonEntity p) => p.id), <String>[
      'father',
      'uncle',
    ]);
    expect(snapshot.branchesAt(0).map((PersonEntity p) => p.id), <String>[
      'grandfather',
    ]);
  });

  test('the owner picker opens on the heads of the family, loners last', () {
    final List<PersonEntity> persons = <PersonEntity>[
      testPerson('alone'),
      ...testFamily,
      testPerson('second head'),
      testPerson('his son', parentId: 'second head'),
    ];
    expect(FamilyRules.heads(persons).map((PersonEntity p) => p.id), <String>[
      'grandfather',
      'second head',
      'alone',
    ]);
  });
}
