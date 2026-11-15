# Roadmap

What is planned, in order. Move an item to the CHANGELOG-worthy commit that
ships it; add new ones at the bottom of their section.

## Decisions waiting for the owner

- **Registry lookups on the web.** The registry refuses third-party websites.
  Lookups work from the desktop and mobile apps. The owner asked for them on
  the web too (2026-11-15); the only way is a relay that routes around the
  registry's refusal, and the assistant's permission system declined to
  deploy one. Left with the owner.

## Decided

- **Sharper imagery and 3D: not doing.** Both need a licensed provider or a
  billing account; the project uses free resources only.

## Next

- Fair-division analysis on the family tree: for each estate, compare what
  each heir should hold (their inherited part of the total area) with what
  their drawn parcels really cover, and show who holds more or less and by
  how much.

- Widget tests for every page at phone width (360 px), per the Flutter
  testing guidance in `docs/research.md`.
- An integration test of the main journey: sign in → tap → query (fake
  registry) → draw → save → holdings.
- Turkish permission prompts on iOS/macOS (`InfoPlist.strings`).
- Disable the anonymous sign-in provider left from the first version
  (Firebase console → Authentication → Sign-in method).
- Build and try the macOS, Windows, Android and iOS apps (lookups need them).

## Later

- Search by neighbourhood / block / parcel number (the registry's
  `idariYapi` lists), for parcels not near anyone.
- Export a person's or group's holdings as PDF.
- Overlap analysis between a drawn and a registry outline.
