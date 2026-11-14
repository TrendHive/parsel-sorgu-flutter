---
name: architecture-rules
description: Where Parcel Atlas's architecture rules and their reasons live, by kind of change — layer imports, ports, entities/value objects/read models, use cases and Cubits, repositories/services/mappers/DTOs, exceptions and causes, constants, copy. Use when writing, moving or reviewing code under lib/ and the one-line rule in CLAUDE.md is not enough to decide.
---

# Architecture rules — read only the section the change needs

`CLAUDE.md` states the rules in one line each; `architecture.md` holds the
reasons; `docs/research.md` maps them to Flutter's official recommendations.

| You are touching | Read |
|---|---|
| An import across layers | CLAUDE.md layer table; architecture.md "The dependency rule" |
| Something new from outside the app (storage, location, an API) | a port `*Interface` in `domain/<feature>/interface/`, an implementation in `infrastructure/`, registration in `main.dart` |
| An entity / value object / read model | CLAUDE.md rule 4; `lib/core/base/` |
| A use case or Cubit | rules 5–6; a page has exactly one Cubit, state is `sealed` |
| The registry (TKGM) | the `registry-quota` skill; `docs/tkgm-api.md` |
| Firestore data or rules | `docs/data-model.md`; every write = change + activity line in one batch |
| A user-visible error | a `BaseCause` in `lib/core/cause/` + its `CauseCode` + a case in `ExceptionCopy` + both `.arb` files |
| Copy | the `i18n-copy` skill |
| A measurement, colour or number | `BaseDimens` / `ParcelInfoDimens` / `ParcelInfoColor` / `CoreConstants` / a `*Rules` class |

## Before handing off

The gate: `flutter analyze` (0 issues), `dart run tool/check_structure.dart`,
`flutter test`. A changed rule updates CLAUDE.md, architecture.md and README
in the same change (rule 17).
