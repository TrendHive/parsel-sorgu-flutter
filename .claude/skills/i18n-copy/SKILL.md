---
name: i18n-copy
description: Adding or changing user-visible text in Parcel Atlas — keys in app_tr.arb (the template, Turkish) and app_en.arb, ICU plurals and placeholders, regenerating, and using them through ParcelInfoLocalKeys. Use whenever any text a user reads is added, reworded or removed.
---

# Copy

Turkish lives only in `lib/domain_ui/values/l10n/app_tr.arb` (rule 13);
`tool/check_structure.dart` fails on Turkish anywhere else.

1. Add the key to `app_tr.arb` first (the template) — natural Turkish; then
   the same key to `app_en.arb` with a real English translation.
2. Placeholders are declared in `app_tr.arb` under `@key.placeholders`
   (`{"type": "String"}`; `int` for plural counts) and spelled identically in
   both files. Counts use ICU plurals: `{count, plural, =0{…} =1{…} other{…}}`.
3. `flutter gen-l10n`, then read it as `ParcelInfoLocalKeys.of(context).key`.
4. A new error message is a cause → `ExceptionCopy` case → key.
5. Delete keys nobody reads.
