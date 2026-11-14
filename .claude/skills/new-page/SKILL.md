---
name: new-page
description: Checklist for adding a routed page to Parcel Atlas — page folder with one body, its Cubit and sealed state in application, the route in ParcelInfoRouter, copy in both .arb files, registration in main.dart, and a widget test. Use whenever a new screen is created, renamed or removed.
---

# New page

1. **Folder:** `lib/presentation/<page>/<page>_page.dart` (a `ParcelInfoScaffold`
   and a `BlocProvider` creating the Cubit from `getIt`), `body/<page>_body.dart`
   (exactly one), then `widgets/`, `dialog/` as needed.
2. **Cubit:** `lib/application/<feature>/cubit/<page>_cubit.dart` + `<page>_state.dart`
   (`part`), state `sealed` with one variant per thing shown (loading, failed,
   ready…). The Cubit calls use cases only and cancels subscriptions in
   `close()`.
3. **Route:** a `RoutePath` and a `GoRoute` in
   `lib/presentation/router/parcel_info_router.dart`. Never a path literal at
   a call site.
4. **Registration:** the Cubit (`registerFactory`) and any new use case in
   `main.dart`.
5. **Copy:** every string through `ParcelInfoLocalKeys.of(context)` — the
   `i18n-copy` skill.
6. **Test:** a widget test pumping the page at 360 px wide with fake ports.
7. **Gate**, then the `pr-flow` skill.
