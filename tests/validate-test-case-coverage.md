---
name: validate-test-case-coverage
description: Goes through every spec test case ID in order, finds the corresponding test in code, and marks each as complete, partial, or absent. Run this after tagging tests with spec IDs.
---

Ask the user for the path to the repository where the tests live if not already provided.

Read the project's `CLAUDE.md` to find:
- Which markdown file holds the spec (where the test case IDs live)
- Where the test files are within that repo

Then read the spec file and collect every test case ID in document order (e.g. `MAP-GOTO-01`, `LOCATION-CREATE-03`, etc.).

Process them one at a time, from top to bottom, without pausing for confirmation between cases.

## Mindset: be a critic of the test, not a reviewer of the spec

Do not take the test at face value. A test that exists and has the right name is not evidence that the spec step is covered. Your job is to read the test code with suspicion and ask: does this test actually prove what the spec claims?

Default to skepticism. A test with a plausible name and a passing assertion is not the same as a test that proves the spec step.

## For each test case

### Step 1 — Find the test

Search all test files in the provided repository for the spec ID string (e.g. `grep -rn "MAP-GOTO-01" <repo>/test`). A test is considered tagged when its `it()` description contains `[MAP-GOTO-01]`.

If no test is found: leave the spec line as `[ ]` and continue to the next case.

If two or more tests share the same ID: run steps 2–4 on each test individually, then mark the spec line `[~]` and add sub-bullets reporting what each test does and what the problem is — one sub-bullet per test. For example:
  ```
  - [~] `MAP-GOTO-03` Нажать «Перейти» → окно закрывается, карта перемещается
    - тест 1: проверяет только перемещение карты, закрытие окна не проверяется
    - тест 2: дублирует тест 1, проверяет тот же сценарий через Enter
  ```

### Step 2 — Analyse the arrangement

Read the test's setup: render functions, fake adapters, mock factories, `beforeEach` blocks, and any helpers they call. Trace into them — do not assume a helper does what its name says.

Ask:
- Does the component render in a state that matches the precondition the spec step assumes?
- Do the fakes and mocks behave realistically enough to exercise the real code path, or do they silently bypass the condition the spec depends on?
- Is the initial data correct — right types, realistic values, required fields present?
- Is anything stubbed out that the spec step depends on?

### Step 3 — Analyse the action

Read the user action performed in the test body. Trace into any action helpers.

Ask:
- Does the test exercise the exact user action described in the spec (the right element, the right sequence of steps)?
- Is it a shortcut that skips steps the spec requires?
- Could the action succeed for the wrong reason?

### Step 4 — Analyse the assertion

Read every assertion the test makes. Trace into any assertion helpers — read their implementation. Do not assume a helper asserts what its name suggests. Only stop tracing when you reach a concrete matcher (`toBe`, `toEqual`, `not.toBeNull`, `toBeDisabled`, etc.) or a well-known library call.

Ask:
- Does the test assert the *outcome* described in the spec, or only a side effect or intermediate state?
- Could the assertion pass even if the feature is broken in the way the spec cares about?
- Is the assertion tight enough, or does it only verify that *something* happened rather than *what* happened?
- If the spec step says two things happen, are both asserted?
- Is any helper a no-op, a trivial pass, or asserting something unrelated?

### Step 5 — Mark the result

**Full match** — arrangement, action, and assertion all align with the spec step:
- Mark the spec line `[x]`.

**Partial match** — the test IS attempting to verify the spec step, but doesn't cover all aspects of it:
- Keep the spec ID tag in the `it()` description.
- Mark the spec line `[~]`.
- Add a sub-bullet under the spec line with a brief observation — a few words on what is wrong, no fix suggested:
  ```
  - [~] `MAP-GOTO-01` Нажать «Перейти по координатам» → открывается модальное окно, кнопка «Перейти» недоступна
    - кнопка disabled не проверяется
  ```
Do not fix the test — leave that to the developer.

**Wrong match** — the test is NOT exercising the spec step at all; it was tagged with the ID but tests a fundamentally different scenario:
- Remove the spec ID tag from the `it()` description (strip `[SPEC-ID]`, leave the rest intact).
- Mark the spec line `[ ]`.

Do not fix the test — leave that to the developer.

## Notation reference

| Spec symbol | Meaning |
|---|---|
| `[x]` | Single test, arrangement/action/assertion fully match the spec step |
| `[~]` | Test found but incomplete, split, or mismatched — observation in sub-bullet |
| `[ ]` | No test found |
