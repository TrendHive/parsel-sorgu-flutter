import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../../support/fakes.dart';

void main() {
  final List<PersonEntity> married = <PersonEntity>[
    ...testFamily,
    testPerson('mother', spouseId: 'father'),
  ];

  PersonEntity byId(String id) =>
      married.firstWhere((PersonEntity p) => p.id == id);

  test('a spouse is found from either record', () {
    expect(FamilyRules.spouseOf(married, byId('mother'))?.id, 'father');
    expect(FamilyRules.spouseOf(married, byId('father'))?.id, 'mother');
    expect(FamilyRules.spouseOf(married, byId('uncle')), isNull);
  });

  test("a wife who married in shares her husband's children", () {
    expect(
      FamilyRules.familyChildrenOf(
        married,
        byId('mother'),
      ).map((PersonEntity p) => p.id),
      <String>['a', 'b', 'c', 'd'],
    );
  });

  test('a wife who married in sits beside her husband, not at the top', () {
    expect(FamilyRules.besideSpouse(married, byId('mother')), isTrue);
    expect(FamilyRules.besideSpouse(married, byId('father')), isFalse);
    expect(FamilyRules.heads(married).map((PersonEntity p) => p.id), <String>[
      'grandfather',
    ]);
  });

  test('a marriage does not change who inherits', () {
    expect(
      FamilyRules.inheritedPart(married, ancestorId: 'father', heirId: 'a'),
      ShareValueObject(1, 4),
    );
    expect(
      FamilyRules.inheritedPart(married, ancestorId: 'mother', heirId: 'a'),
      isNull,
    );
  });

  test('marrying oneself, one\'s own line or a married person is refused', () {
    final PersonEntity stranger = testPerson('stranger');
    final List<PersonEntity> family = <PersonEntity>[...married, stranger];
    bool can(PersonEntity person, String spouseId) =>
        FamilyRules.canBeSpouse(family, person: person, spouseId: spouseId);
    expect(can(stranger, 'stranger'), isFalse);
    expect(can(byId('a'), 'grandfather'), isFalse);
    expect(can(byId('grandfather'), 'a'), isFalse);
    expect(can(stranger, 'father'), isFalse);
    expect(can(stranger, 'uncle'), isTrue);
    expect(can(byId('mother'), 'father'), isTrue);
  });

  test("brothers' pieces go back up to their father, cousins' to the "
      'grandfather', () {
    expect(
      FamilyRules.commonAncestor(married, <String>['a', 'b', 'c', 'd'])?.id,
      'father',
    );
    expect(
      FamilyRules.commonAncestor(married, <String>['a', 'uncle'])?.id,
      'grandfather',
    );
    expect(FamilyRules.commonAncestor(married, <String>['a'])?.id, 'a');
    expect(
      FamilyRules.commonAncestor(married, <String>['a', 'mother']),
      isNull,
    );
    expect(FamilyRules.parentOf(married, byId('father'))?.id, 'grandfather');
  });
}
