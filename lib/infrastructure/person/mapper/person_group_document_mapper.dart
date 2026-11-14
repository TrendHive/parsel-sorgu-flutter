import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/person/entity/person_group_entity.dart';
import 'package:parcel_atlas/infrastructure/store/mapper/audit_stamp_mapper.dart';

/// A group as a store document, and back.
class PersonGroupDocumentMapper {
  const PersonGroupDocumentMapper();

  static const String name = 'name';
  static const String memberIds = 'memberIds';
  static const String note = 'note';
  static const String created = 'created';
  static const String updated = 'updated';

  static const AuditStampMapper _stamps = AuditStampMapper();

  Map<String, Object?> write(PersonGroupEntity group) => <String, Object?>{
    name: group.name,
    memberIds: group.memberIds,
    note: group.note,
  };

  PersonGroupEntity? read(String id, Map<String, dynamic> data) {
    final Object? members = data[memberIds];
    return PersonGroupEntity(
      id: id,
      name: '${data[name] ?? CoreConstants.empty}',
      memberIds: <String>[
        if (members is List)
          for (final Object? member in members)
            if (member is String) member,
      ],
      note: '${data[note] ?? CoreConstants.empty}',
      created: _stamps.readOptional(data[created]),
      updated: _stamps.readOptional(data[updated]),
    );
  }
}
