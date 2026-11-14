/// A domain object tracked by its identity, not by its fields.
///
/// A parcel whose note is edited is still that parcel, so two entities are equal
/// when they are the same type with the same [id] — whatever else differs.
/// [id] is the entity's own id, or the one thing it belongs to one-to-one
/// (a parcel answers its registry key).
///
/// Equality lives here, once, rather than in thirty hand-written `==`s that
/// drift apart: an entity that forgot `hashCode` is a set that holds the same
/// parcel twice.
abstract class BaseEntity {
  const BaseEntity();

  String get id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is BaseEntity &&
          other.id == id);

  @override
  int get hashCode => Object.hash(runtimeType, id);
}
