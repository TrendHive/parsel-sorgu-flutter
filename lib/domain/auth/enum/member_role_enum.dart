/// What a family member may do.
///
/// [admin] is the main account: everything a [member] can, plus deleting
/// records — the one action that cannot be undone, so it rests with one
/// person. Firestore's rules enforce the same split; the app only mirrors it
/// to hide buttons that would be refused.
enum MemberRoleEnum { admin, member }
