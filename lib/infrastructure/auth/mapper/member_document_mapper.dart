import 'package:parcel_atlas/core/constants.dart';
import 'package:parcel_atlas/domain/auth/entity/member_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';

/// A member's profile document (`members/{uid}`), written by
/// `tool/add_member.dart` and only read by the app.
class MemberDocumentMapper {
  const MemberDocumentMapper();

  static const String name = 'name';
  static const String username = 'username';
  static const String role = 'role';

  MemberEntity read(String id, Map<String, dynamic> data) => MemberEntity(
    id: id,
    name: '${data[name] ?? CoreConstants.empty}',
    username: '${data[username] ?? CoreConstants.empty}',
    role: data[role] == MemberRoleEnum.admin.name
        ? MemberRoleEnum.admin
        : MemberRoleEnum.member,
  );
}
