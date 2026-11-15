import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// The family tree's arithmetic: who descends from whom, and what part of
/// an ancestor's share reaches an heir.
///
/// [childrenOf] is a person's children. [isDescendant] walks up from a
/// person to see whether an ancestor is above them; [canBeParent] refuses a
/// link that would make someone their own ancestor.
///
/// [passes] is whether a person's shares go on to children: they are marked
/// so and have at least one child. [inheritedPart] is the fraction of an
/// ancestor's share that reaches an heir — at each generation the share is
/// split equally among the children, and it stops at the first person whose
/// shares have not passed on. It is null when nothing reaches the heir.
///
/// Every walk is bounded by [maxGenerations], so a corrupt record that
/// loops cannot hang the app.
abstract final class FamilyRules {
  static const int maxGenerations = 32;

  static List<PersonEntity> childrenOf(
    List<PersonEntity> persons,
    String personId,
  ) => persons.where((PersonEntity p) => p.parentId == personId).toList();

  static bool passes(List<PersonEntity> persons, PersonEntity person) =>
      person.passesToChildren && childrenOf(persons, person.id).isNotEmpty;

  static bool isDescendant(
    List<PersonEntity> persons, {
    required String personId,
    required String ancestorId,
  }) => _pathDown(persons, ancestorId, personId) != null;

  static bool canBeParent(
    List<PersonEntity> persons, {
    required String childId,
    required String parentId,
  }) =>
      childId != parentId &&
      !isDescendant(persons, personId: parentId, ancestorId: childId);

  static ShareValueObject? inheritedPart(
    List<PersonEntity> persons, {
    required String ancestorId,
    required String heirId,
  }) {
    final List<PersonEntity>? path = _pathDown(persons, ancestorId, heirId);
    if (path == null || path.length < 2) return null;
    ShareValueObject part = ShareValueObject.whole;
    for (int i = 0; i < path.length - 1; i++) {
      if (!path[i].passesToChildren) return null;
      part = part.dividedBy(childrenOf(persons, path[i].id).length);
    }
    return part;
  }

  static List<PersonEntity>? _pathDown(
    List<PersonEntity> persons,
    String fromId,
    String toId,
  ) {
    final Map<String, PersonEntity> byId = <String, PersonEntity>{
      for (final PersonEntity p in persons) p.id: p,
    };
    final List<PersonEntity> up = <PersonEntity>[];
    PersonEntity? current = byId[toId];
    for (int i = 0; i < maxGenerations && current != null; i++) {
      up.add(current);
      if (current.id == fromId) return up.reversed.toList();
      current = byId[current.parentId];
    }
    return null;
  }
}
