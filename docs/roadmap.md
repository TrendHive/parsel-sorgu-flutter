# Roadmap

What is planned, in order. Move an item to the CHANGELOG-worthy commit that
ships it; add new ones at the bottom of their section.

## Decisions waiting for the owner

- **Registry lookups on the web.** The registry refuses third-party websites.
  Options: (a) keep lookups to the desktop/mobile apps (works today);
  (b) a small relay the family controls that forwards lookups — it would
  route around the registry's refusal, so it is the owner's call and needs an
  account with a host.
- **Sharper imagery and 3D.** Free aerial imagery stops at level 18 for the
  area. Sharper tiles need a licensed provider (an API key, usually a billing
  account, even where a free allowance exists); 3D terrain needs a different
  map engine (for example MapLibre) and is a rewrite of the map page.

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
