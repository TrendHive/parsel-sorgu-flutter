# Agents — Parcel Atlas

The lead works inline by default; these are for large or parallel work.

| Agent | When |
|---|---|
| `flutter-developer` | A feature or fix across layers, with tests. |
| `code-reviewer` | Once per PR, read-only, diff-scoped; blocks on any rule. |

Pipeline: `flutter-developer` → `code-reviewer` → `pr-flow` skill.
