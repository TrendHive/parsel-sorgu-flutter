# Roadmap

What is planned, in order. Move an item to the CHANGELOG-worthy commit that
ships it; add new ones at the bottom of their section.

## Next

- Widget tests for every page at phone width (360 px), per the Flutter
  testing guidance in `docs/research.md`.
- An integration test of the main journey: sign in → tap → query (fake
  registry) → draw → save → holdings.
- Turkish permission prompts on iOS/macOS (`InfoPlist.strings`).
- Disable the anonymous sign-in provider left from the first version
  (Firebase console → Authentication → Sign-in method).

## Later

- Search by neighbourhood / block / parcel number (the registry's
  `idariYapi` lists), for parcels not near anyone.
- Export a person's or group's holdings as PDF.
- Overlap analysis between a drawn and a registry outline.
