---
name: add-member
description: How family sign-in accounts are created for Parcel Atlas — tool/add_member.dart, run by a person in their own terminal, never through Claude, since it reads a password. Use when someone asks to add, re-add or promote a user, or asks why someone cannot sign in.
---

# Adding a member

Accounts are fixed; the app has no sign-up. A person runs, in their own
terminal (the tool refuses without one, and the password must not pass
through a chat):

```bash
dart run tool/add_member.dart <username> "<Display name>" [--admin]
```

It creates `<username>@members.parcel-atlas.app`, adds the account id to
`memberIds()` (and `adminIds()` with `--admin`) in `firestore.rules`, deploys
the rules, and writes `members/{uid}`. Commit the rules change afterwards.

Sign-in accounts are not parcel owners: owners are `persons` / `groups`,
created in the app.

"Cannot sign in": wrong password → the member re-runs nothing, the admin
resets it in the Firebase console; "not on the family's list" → the id is
missing from `firestore.rules` or the profile was not written — re-run the
tool for that username (it signs in instead of creating).
