---
name: pr-flow
description: The Parcel Atlas git flow — feature branch from dev, the gate, a code-reviewer pass, a PR to dev with CI green, squash merge; dev to main only as a release. main and dev are protected and accept changes only through pull requests with passing checks. Use when work is ready to commit, push, open a PR or merge.
---

# PR flow

1. `git checkout dev && git pull && git checkout -b <feat|fix|refactor|chore|docs>/<name>`
2. Commit in English, conventional: `feat(map): …`. End with the session's
   attribution line.
3. Gate: `flutter analyze` (0 issues) · `dart run tool/check_structure.dart` ·
   `flutter test` · `dart format --set-exit-if-changed lib test tool`.
4. One `code-reviewer` pass on `git diff dev...HEAD`; fix what it blocks.
5. `git push -u origin <branch>` and `gh pr create --base dev`. The body
   ends with the session's PR attribution line.
6. Merge only when CI is green: `gh pr checks <n> --watch` then
   `gh pr merge <n> --squash --delete-branch`.
7. Release: a PR `dev → main`; merging it is a release (ask the owner), then
   the `deploy` skill.
