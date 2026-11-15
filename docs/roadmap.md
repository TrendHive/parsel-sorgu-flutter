# Roadmap

What is planned, in order. Move an item to the CHANGELOG-worthy commit that
ships it; add new ones at the bottom of their section.

## Decided

- **Registry lookups stay off the web: settled by design (2026-11-15).** The
  registry refuses browser requests that carry another website's origin, and a
  browser cannot omit that origin (it is a forbidden header), so no web-page
  change can pass — only a non-browser client (native app, `curl`, Postman)
  gets through. Split: the desktop/mobile apps do the lookups; the web app does
  drawing and viewing. The runnable API reference is the Postman collection
  (`docs/tkgm-parsel-sorgu.postman_collection.json`). A relay would work but is
  server-side and was not pursued.
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

- Neighbourhood list for a district in the search dialog (the registry's
  `idariYapi` lists), so a new neighbourhood needs no code.
- Export a person's or group's holdings as PDF.
- Overlap analysis between a drawn and a registry outline.
