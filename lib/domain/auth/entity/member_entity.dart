import 'package:parcel_atlas/core/base/base_entity.dart';
import 'package:parcel_atlas/domain/auth/enum/member_role_enum.dart';

/// A family member who signs in — the "who" on every change.
///
/// Accounts are fixed: they are created with `tool/add_member.dart`, never
/// from the app, so [username] is the short name a member types and [name]
/// is how their changes are signed. [id] is the sign-in account's id.
final class MemberEntity extends BaseEntity {
  const MemberEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
  });

  @override
  final String id;

  final String name;

  final String username;

  final MemberRoleEnum role;

  bool get canDelete => role == MemberRoleEnum.admin;
}
