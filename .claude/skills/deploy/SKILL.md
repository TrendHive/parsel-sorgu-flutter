---
name: deploy
description: Publishing Parcel Atlas to Firebase Hosting (parcel-info.web.app) and deploying Firestore rules/indexes and auth settings — free Spark plan only. Use when asked to deploy, publish, release or push the site live.
---

# Deploy

Only from `main`, after the PR from `dev` merged with a green gate. Ask the
owner before a production deploy unless they asked for it.

```bash
flutter build web --release
firebase deploy --project parcel-info            # hosting + firestore + auth
# or narrower: --only hosting | --only firestore:rules | --only auth
```

After deploying: open https://parcel-info.web.app, sign in, tap a stored
parcel (no registry call), and check the browser console is clean. Never
enable a paid product (Blaze, Functions, Storage beyond Spark).
