import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/entity/person_entity.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';

/// A person as a store document, and back.
class PersonDocumentMapper {
  const PersonDocumentMapper();

  static const String name = 'name';
  static const String note = 'note';
  static const String created = 'created';
  static const String updated = 'updated';

  static const AuditStampMapper _stamps = AuditStampMapper();

  Map<String, Object?> write(PersonEntity person) => <String, Object?>{
    name: person.name,
    note: person.note,
  };

  PersonEntity? read(String id, Map<String, dynamic> data) => PersonEntity(
    id: id,
    name: '${data[name] ?? CoreConstants.empty}',
    note: '${data[note] ?? CoreConstants.empty}',
    created: _stamps.readOptional(data[created]),
    updated: _stamps.readOptional(data[updated]),
  );
}
