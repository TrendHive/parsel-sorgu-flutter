---
name: bug-fix
description: The Parcel Atlas regression discipline — reproduce, write a test named after the symptom that fails first, minimal fix, a mechanical guard where possible, and a docs/regressions.md entry. Use for any wrong behaviour, crash or bug found in review; skip for typos and copy tweaks.
---

# Bug fix

1. **Reproduce** and find the root cause, not the nearest symptom.
2. **Test first**, named after what the user saw ("a tap inside a stored
   parcel never spends a registry lookup"). Run it; it must fail.
3. **Minimal fix**; the test passes.
4. **Guard:** prefer a check in `tool/check_structure.dart`, then a lint in
   `analysis_options.yaml`, then a type that makes the state impossible.
5. **Record the class** in `docs/regressions.md`: bold symptom, short root
   cause, `*Guard:*` naming the test or rule.
6. Gate, then `pr-flow`.
