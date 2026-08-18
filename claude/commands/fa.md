---
description: Apply every finding from the review produced earlier in this session
disable-model-invocation: true
argument-hint: [which findings, e.g. 2-4]
---

Apply the findings from the review output earlier in this session. $ARGUMENTS narrows which ones;
empty means all of them.

1. No review output in this session: say so and stop. Do not go looking for problems to invent.
2. Fix root causes, not the symptom each finding names. Grep every caller before editing a shared
   function: one guard where the callers converge beats a guard in each of them.
3. Do not expand scope. A finding is a fix, not an invitation to refactor around it.
4. Run whatever check the repository already has for the code you touched.
5. Report one line per finding: fixed, or skipped and why. Say plainly when a finding was wrong.

Do not commit. That is what /c, /cp, /cm and friends are for.
