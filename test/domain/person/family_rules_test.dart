import 'package:flutter_test/flutter_test.dart';
import 'package:parcel_atlas/domain/person/rule/family_rules.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

import '../../support/fakes.dart';

void main() {
  test("a grandchild gets an eighth of the grandfather's land", () {
    expect(
      FamilyRules.inheritedPart(
        testFamily,
        ancestorId: 'grandfather',
        heirId: 'a',
      ),
      ShareValueObject(1, 8),
    );
  });

  test('a child gets a quarter of the father and a son half of his father', () {
    expect(
      FamilyRules.inheritedPart(testFamily, ancestorId: 'father', heirId: 'c'),
      ShareValueObject(1, 4),
    );
    expect(
      FamilyRules.inheritedPart(
        testFamily,
        ancestorId: 'grandfather',
        heirId: 'uncle',
      ),
      ShareValueObject(1, 2),
    );
  });

  test('nothing passes from someone whose shares have not passed on', () {
    expect(
      FamilyRules.inheritedPart(testFamily, ancestorId: 'uncle', heirId: 'a'),
      isNull,
    );
    expect(
      FamilyRules.inheritedPart(
        [testPerson('p'), testPerson('child', parentId: 'p')],
        ancestorId: 'p',
        heirId: 'child',
      ),
      isNull,
    );
  });

  test('nobody can become the child of their own descendant', () {
    expect(
      FamilyRules.canBeParent(
        testFamily,
        childId: 'grandfather',
        parentId: 'a',
      ),
      isFalse,
    );
    expect(
      FamilyRules.canBeParent(testFamily, childId: 'a', parentId: 'a'),
      isFalse,
    );
    expect(
      FamilyRules.canBeParent(testFamily, childId: 'a', parentId: 'uncle'),
      isTrue,
    );
  });

  test('a looping record does not hang the walk', () {
    final loop = [
      testPerson('x', parentId: 'y', passesToChildren: true),
      testPerson('y', parentId: 'x', passesToChildren: true),
    ];
    expect(
      FamilyRules.isDescendant(loop, personId: 'x', ancestorId: 'nobody'),
      isFalse,
    );
  });
}
