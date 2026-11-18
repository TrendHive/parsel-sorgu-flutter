import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/domain/person/value_object/share_value_object.dart';

/// The family tree's arithmetic: who descends from whom, and what part of
/// an ancestor's share reaches an heir.
///
/// [childrenOf] is a person's children. [heads] is the top of the tree, as
/// a picker shows it: the people with no parent in the list, the heads of a
/// family (those with children) first and people on their own after them;
/// a spouse who married in is left out, as they are shown beside their
/// spouse. [isDescendant] walks up from a
/// person to see whether an ancestor is above them; [canBeParent] refuses a
/// link that would make someone their own ancestor.
///
/// [passes] is whether a person's shares go on to children: they are marked
/// so and have at least one child. [inheritedPart] is the fraction of an
/// ancestor's share that reaches an heir — at each generation the share is
/// split equally among the children, and it stops at the first person whose
/// shares have not passed on. It is null when nothing reaches the heir.
///
/// [depthOf] is how many ancestors a person has — a root is at level zero —
/// and [generations] how many levels the tree has. [holdersAt] answers who,
/// at one level of the tree, a share recorded on a person belongs to: the
/// person's own ancestor at that level, or, for a person above it whose
/// shares passed on, every heir of theirs at that level. It is what colours
/// the map by branch of the family.
///
/// [spouseOf] is a person's husband or wife, whichever of the two records
/// names the other. [canBeSpouse] refuses a marriage to oneself, to one's
/// own ancestor or descendant, or to someone already married to another
/// person. [familyChildrenOf] is a couple's children — the person's own and
/// their spouse's — as a page shows them; shares still pass only through
/// [childrenOf], from the parent the child is recorded under.
/// [besideSpouse] says a person is shown next to their spouse rather than
/// at the top of the tree: they have no parent in the list, and their
/// spouse either has one or is the one the children are recorded under.
///
/// [commonAncestor] is the nearest person every one of `personIds` is or
/// descends from — four brothers give their father, a man and his nephew
/// give the grandfather, one person gives themselves — or null when they
/// have none in common. [parentOf] is a person's parent in the list.
///
/// Every walk is bounded by [maxGenerations], so a corrupt record that
/// loops cannot hang the app.
abstract final class FamilyRules {
  static const int maxGenerations = 32;

  static List<PersonEntity> childrenOf(
    List<PersonEntity> persons,
    String personId,
  ) => persons.where((PersonEntity p) => p.parentId == personId).toList();

  static List<PersonEntity> heads(List<PersonEntity> persons) {
    final Set<String> ids = <String>{
      for (final PersonEntity p in persons) p.id,
    };
    final List<PersonEntity> top = persons
        .where(
          (PersonEntity p) =>
              !ids.contains(p.parentId) && !besideSpouse(persons, p),
        )
        .toList();
    bool hasChildren(PersonEntity p) => childrenOf(persons, p.id).isNotEmpty;
    return <PersonEntity>[
      ...top.where(hasChildren),
      ...top.where((PersonEntity p) => !hasChildren(p)),
    ];
  }

  static PersonEntity? spouseOf(
    List<PersonEntity> persons,
    PersonEntity person,
  ) {
    for (final PersonEntity p in persons) {
      if (p.id == person.id) continue;
      if (p.id == person.spouseId || p.spouseId == person.id) return p;
    }
    return null;
  }

  static bool canBeSpouse(
    List<PersonEntity> persons, {
    required PersonEntity person,
    required String spouseId,
  }) {
    if (spouseId == person.id) return false;
    if (isDescendant(persons, personId: spouseId, ancestorId: person.id) ||
        isDescendant(persons, personId: person.id, ancestorId: spouseId)) {
      return false;
    }
    final PersonEntity? current = spouseOf(persons, person);
    if (current != null && current.id != spouseId) return false;
    final PersonEntity? candidate = persons
        .where((PersonEntity p) => p.id == spouseId)
        .firstOrNull;
    if (candidate == null) return false;
    final PersonEntity? theirs = spouseOf(persons, candidate);
    return theirs == null || theirs.id == person.id;
  }

  static List<PersonEntity> familyChildrenOf(
    List<PersonEntity> persons,
    PersonEntity person,
  ) {
    final PersonEntity? spouse = spouseOf(persons, person);
    return <PersonEntity>[
      ...childrenOf(persons, person.id),
      if (spouse != null) ...childrenOf(persons, spouse.id),
    ];
  }

  static bool besideSpouse(List<PersonEntity> persons, PersonEntity person) {
    bool hasParent(PersonEntity p) =>
        persons.any((PersonEntity other) => other.id == p.parentId);
    if (hasParent(person)) return false;
    final PersonEntity? spouse = spouseOf(persons, person);
    if (spouse == null) return false;
    return hasParent(spouse) ||
        (childrenOf(persons, person.id).isEmpty &&
            childrenOf(persons, spouse.id).isNotEmpty);
  }

  static PersonEntity? commonAncestor(
    List<PersonEntity> persons,
    Iterable<String> personIds,
  ) {
    final List<List<PersonEntity>> paths = <List<PersonEntity>>[
      for (final String id in personIds.toSet()) _pathUp(persons, id),
    ];
    if (paths.isEmpty || paths.any((List<PersonEntity> p) => p.isEmpty)) {
      return null;
    }
    for (final PersonEntity candidate in paths.first) {
      if (paths.every(
        (List<PersonEntity> path) =>
            path.any((PersonEntity p) => p.id == candidate.id),
      )) {
        return candidate;
      }
    }
    return null;
  }

  static PersonEntity? parentOf(
    List<PersonEntity> persons,
    PersonEntity person,
  ) => persons.where((PersonEntity p) => p.id == person.parentId).firstOrNull;

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

  static int depthOf(List<PersonEntity> persons, String personId) =>
      _pathUp(persons, personId).length - 1;

  static int generations(List<PersonEntity> persons) => persons.fold(
    0,
    (int most, PersonEntity p) =>
        depthOf(persons, p.id) + 1 > most ? depthOf(persons, p.id) + 1 : most,
  );

  static Set<String> holdersAt(
    List<PersonEntity> persons,
    String personId,
    int level,
  ) {
    final List<PersonEntity> up = _pathUp(persons, personId);
    if (up.isEmpty) return <String>{};
    final int depth = up.length - 1;
    if (depth >= level) return <String>{up[depth - level].id};
    if (!passes(persons, up.first)) return <String>{personId};
    return <String>{
      for (final PersonEntity child in childrenOf(persons, personId))
        ...holdersAt(persons, child.id, level),
    };
  }

  static List<PersonEntity> _pathUp(
    List<PersonEntity> persons,
    String personId,
  ) {
    final Map<String, PersonEntity> byId = <String, PersonEntity>{
      for (final PersonEntity p in persons) p.id: p,
    };
    final List<PersonEntity> up = <PersonEntity>[];
    PersonEntity? current = byId[personId];
    for (int i = 0; i < maxGenerations && current != null; i++) {
      up.add(current);
      current = byId[current.parentId];
    }
    return up;
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
